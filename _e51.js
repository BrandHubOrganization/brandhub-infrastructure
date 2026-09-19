const fs=require("fs");
const env=fs.readFileSync(".env","utf8");
const g=k=>{const m=env.match(new RegExp(k+"=(.+)","i"));return m?m[1].trim():null};
const SITE=g("JIRA_SITE"), EMAIL=g("JIRA_EMAIL"), TOKEN=g("JIRA_API_TOKEN");
const auth="Basic "+Buffer.from(EMAIL+":"+TOKEN).toString("base64");
async function j(path,opt){const r=await fetch("https://"+SITE+path,{headers:{Authorization:auth,Accept:"application/json"},...opt});return {s:r.status,j:await r.json()};}
(async()=>{
  // list E51 epic child issues
  const q=`project=DA AND "Epic Link"=DA-939 ORDER BY key ASC`;
  const r=await j("/rest/api/3/search/jql?jql="+encodeURIComponent(q)+"&maxResults=50&fields=summary,key,issuetype,assignee,labels,priority");
  console.log("count", r.j.total);
  for(const i of (r.j.issues||[])) console.log(i.key, "|", i.fields.issuetype.name, "|", (i.fields.assignee&&i.fields.assignee.displayName)||"-", "|", (i.fields.labels||[]).join(","), "|", i.fields.summary.slice(0,80));
})();
