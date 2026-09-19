const fs=require("fs");
const raw=fs.readFileSync("Các FR của hệ thống  - Feature_Function Requirement.csv","utf8");
// simple CSV parse handling quotes
function parse(s){const rows=[];let row=[],cur="",q=false;
 for(let i=0;i<s.length;i++){const c=s[i];
  if(q){if(c=='"'){if(s[i+1]=='"'){cur+='"';i++;}else q=false;}else cur+=c;}
  else if(c=='"')q=true;
  else if(c==','){row.push(cur);cur="";}
  else if(c=='\n'||c=='\r'){if(c=='\r'&&s[i+1]=='\n')i++; row.push(cur);rows.push(row);row=[];cur="";}
  else cur+=c;}
 if(cur.length||row.length){row.push(cur);rows.push(row);}
 return rows;}
const rows=parse(raw);
const hdr=rows[0];
console.log("cols:",JSON.stringify(hdr));
console.log("total data rows:",rows.length-1);
// map column index
const ci={}; hdr.forEach((h,i)=>ci[h.trim()]=i);
console.log("Code col idx:",ci["Code"],"Tiêu đề:",ci["Tiêu đề"],"Tên FR:",ci["Tên FR"],"Người làm TL:",ci["Người làm tài liệu "]);
// count FRs with Code filled
const frs=rows.slice(1).filter(r=>r[ci["Tiêu đề"]] && r[ci["Tiêu đề"]].trim());
console.log("FR rows (has Tiêu đề):",frs.length);
const withCode=frs.filter(r=>r[ci["Code"]] && r[ci["Code"]].trim());
console.log("with Code filled:",withCode.length);
const codeDist={}; for(const r of withCode){const c=r[ci["Code"]].trim(); codeDist[c]=(codeDist[c]||0)+1;}
console.log("Code dist:",JSON.stringify(codeDist));
// sample of FR with Code for notification area
const noti=frs.filter(r=>/notif/i.test(r[ci["Tên FR"]]||"")||/notif/i.test(r[ci["Thay đổi / Mô Tả"]]||""));
console.log("\nNotification FRs:");
for(const r of noti) console.log("  "+r[ci["Tiêu đề"]].trim()+" | "+r[ci["Tên FR"]].trim()+" | Code="+(r[ci["Code"]]||"").trim());
fs.writeFileSync("_fr_rows.json",JSON.stringify(frs.map(r=>({id:r[ci["Tiêu đề"]]?.trim(),name:r[ci["Tên FR"]]?.trim(),code:r[ci["Code"]]?.trim(),role:r[ci["Role"]]?.trim(),doc:r[ci["Người làm tài liệu "]]?.trim()}))));
console.log("\nsaved _fr_rows.json");
