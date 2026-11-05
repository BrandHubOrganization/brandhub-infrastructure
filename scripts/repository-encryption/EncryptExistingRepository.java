import com.brandhub.business.config.RepositoryEncryptionProperties;
import com.brandhub.business.service.material.RepositoryEnvelopeCrypto;
import java.nio.file.*;
import java.io.*;
import java.security.MessageDigest;
import java.util.*;
import software.amazon.awssdk.auth.credentials.DefaultCredentialsProvider;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.*;

/** Run with the business-service classpath and its environment. Dry-run unless --apply is provided. */
public class EncryptExistingRepository {
    static String hash(Path file)throws Exception {var md=MessageDigest.getInstance("SHA-256");try(var in=Files.newInputStream(file)){byte[] b=new byte[65536];int n;while((n=in.read(b))!=-1)md.update(b,0,n);}return HexFormat.of().formatHex(md.digest());}
    static void remove(Path file){if(file!=null)try{Files.deleteIfExists(file);}catch(IOException ignored){}}
    public static void main(String[] args)throws Exception {
        boolean apply=Arrays.asList(args).contains("--apply");String bucket=System.getenv("AWS_S3_BUCKET");
        if(bucket==null||bucket.isBlank())throw new IllegalStateException("AWS_S3_BUCKET required");
        var config=new RepositoryEncryptionProperties();config.setEnabled(true);config.setActiveKeyId(System.getenv().getOrDefault("REPOSITORY_ENCRYPTION_ACTIVE_KEY_ID","v1"));
        String secret=System.getenv("REPOSITORY_ENCRYPTION_KEY_V1");if(secret==null||secret.isBlank())throw new IllegalStateException("Backend keyring not configured");config.getKeys().put("v1",secret);
        var crypto=new RepositoryEnvelopeCrypto(config);crypto.requireReady();
        Path backupDir=null;
        if(apply){String location=System.getenv("REPOSITORY_ENCRYPTION_MIGRATION_BACKUP_DIR");if(location==null||location.isBlank())throw new IllegalStateException("Encrypted backup directory required for apply");backupDir=Path.of(location);Files.createDirectories(backupDir);}
        try(var s3=S3Client.builder().region(Region.of(System.getenv().getOrDefault("AWS_S3_REGION","ap-southeast-1"))).credentialsProvider(DefaultCredentialsProvider.create()).build()){
            var versioning=s3.getBucketVersioning(GetBucketVersioningRequest.builder().bucket(bucket).build());
            if(versioning.status()!=null)throw new IllegalStateException("Versioned bucket requires a reviewed version migration; no writes performed");
            var objects=new ArrayList<S3Object>();
            for(String prefix:List.of("repository/","repository-staging/","staging/","client-vault/"))
                s3.listObjectsV2Paginator(ListObjectsV2Request.builder().bucket(bucket).prefix(prefix).build()).contents().forEach(objects::add);
            System.out.println("inventory objects="+objects.size()+" bytes="+objects.stream().mapToLong(S3Object::size).sum()+" apply="+apply);
            int migrated=0,already=0;
            for(var object:objects){
                String key=object.key();if(key.endsWith("/")&&object.size()==0)continue;
                var head=s3.headObject(HeadObjectRequest.builder().bucket(bucket).key(key).build());
                if(RepositoryEnvelopeCrypto.FORMAT.equals(head.metadata().get("bh-encryption"))){already++;continue;}
                if(!apply)continue;
                if(head.metadata().containsKey("bh-encryption"))throw new IllegalStateException("Unknown encrypted format; no overwrite");
                String scope=RepositoryEnvelopeCrypto.scope(key),mime=head.contentType()==null?"application/octet-stream":head.contentType();
                Path plain=null,cipher=null,verified=null,downloaded=null,restored=null;
                try {
                    plain=Files.createTempFile("brandhub-migrate-source-",".bin");verified=Files.createTempFile("brandhub-migrate-check-",".bin");
                    try(var in=s3.getObject(GetObjectRequest.builder().bucket(bucket).key(key).ifMatch(head.eTag()).build());var out=Files.newOutputStream(plain)){in.transferTo(out);}
                    String originalHash=hash(plain);cipher=crypto.encrypt(plain,scope,mime);
                    try(var in=Files.newInputStream(cipher)){crypto.decrypt(in,verified,scope,mime,head.contentLength());}
                    if(!originalHash.equals(hash(verified)))throw new IllegalStateException("Pre-write integrity check failed");
                    String backupId=UUID.randomUUID().toString();
                    Files.copy(cipher,backupDir.resolve(backupId+".cipher"));
                    Files.writeString(backupDir.resolve(backupId+".json"),new com.fasterxml.jackson.databind.ObjectMapper().writeValueAsString(Map.of("bucket",bucket,"key",key,"mime",mime,"bytes",head.contentLength(),"keyId",crypto.activeKeyId(),"sha256",originalHash,"previousETag",head.eTag())));
                    var tags=s3.getObjectTagging(GetObjectTaggingRequest.builder().bucket(bucket).key(key).build()).tagSet();
                    var meta=new HashMap<>(head.metadata());meta.put("bh-encryption",RepositoryEnvelopeCrypto.FORMAT);meta.put("bh-plaintext-bytes",Long.toString(head.contentLength()));meta.put("bh-plaintext-mime",mime);meta.put("bh-key-id",crypto.activeKeyId());
                    var put=PutObjectRequest.builder().bucket(bucket).key(key).contentType("application/octet-stream").metadata(meta).overrideConfiguration(c->c.putHeader("If-Match",head.eTag()));
                    if(!tags.isEmpty())put.tagging(tags.stream().map(t->java.net.URLEncoder.encode(t.key(),java.nio.charset.StandardCharsets.UTF_8)+"="+java.net.URLEncoder.encode(t.value(),java.nio.charset.StandardCharsets.UTF_8)).collect(java.util.stream.Collectors.joining("&")));
                    s3.putObject(put.build(),RequestBody.fromFile(cipher));
                    downloaded=Files.createTempFile("brandhub-migrate-cipher-",".bin");restored=Files.createTempFile("brandhub-migrate-restored-",".bin");
                    try(var in=s3.getObject(GetObjectRequest.builder().bucket(bucket).key(key).build());var out=Files.newOutputStream(downloaded)){in.transferTo(out);}
                    try(var in=Files.newInputStream(downloaded)){crypto.decrypt(in,restored,scope,mime,head.contentLength());}
                    if(!originalHash.equals(hash(restored)))throw new IllegalStateException("Post-write integrity check failed");
                    migrated++;System.out.println("verified_encrypted="+migrated+" total="+objects.size());
                } finally {remove(plain);remove(cipher);remove(verified);remove(downloaded);remove(restored);}
            }
            System.out.println("complete migrated="+migrated+" already_encrypted="+already+" inventory="+objects.size());
        }
    }
}
