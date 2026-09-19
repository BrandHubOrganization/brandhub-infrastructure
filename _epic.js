const fs=require("fs");
const env=fs.readFileSync(".env","utf8");
const g=k=>{const m=env.match(new RegExp(k+"=(.+)","i"));return m?m[1].trim():null};
const SITE=g("JIRA_SITE"), EMAIL=g("JIRA_EMAIL"), TOKEN=g("JIRA_API_TOKEN");
const auth="Basic "+Buffer.from(EMAIL+":"+TOKEN).toString("base64");
async function j(path){const r=await fetch("https://"+SITE+path,{headers:{Authorization:auth,Accept:"application/json"}});return {s:r.status,j:await r.json()};}
(async()=>{
  // find epics named E51 / E53 etc
  const q=`project=DA AND issuetype=Epic AND summary~"Content Task" ORDER BY created DESC`;
  const r=await j("/rest/api/3/search/jql?jql="+encodeURIComponent(q)+"&maxResults=50&fields=summary,key");
  console.log("EPICS:", r.s);
  for(const i of (r.j.issues||[])) console.log(i.key, "|", i.fields.summary);
})();
