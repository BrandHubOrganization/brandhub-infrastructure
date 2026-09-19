const fs=require("fs");
const env=fs.readFileSync(".env","utf8");
const g=k=>{const m=env.match(new RegExp(k+"=(.+)","i"));return m?m[1].trim():null};
const SITE=g("JIRA_SITE"), EMAIL=g("JIRA_EMAIL"), TOKEN=g("JIRA_API_TOKEN");
const auth="Basic "+Buffer.from(EMAIL+":"+TOKEN).toString("base64");
async function j(p){const r=await fetch("https://"+SITE+p,{headers:{Authorization:auth,Accept:"application/json"}});return await r.json();}
const epics={"AI-04":"DA-79","AI-05":"DA-98","AI-06":"DA-97","AI-07":"DA-99","AI-08":"DA-104","AI-09":"DA-110","AI-10":"DA-111"};
(async()=>{
  for(const [name,key] of Object.entries(epics)){
    const q=`project=DA AND parent=${key} ORDER BY key ASC`;
    const r=await j("/rest/api/3/search/jql?jql="+encodeURIComponent(q)+"&maxResults=100&fields=summary,key,assignee");
    console.log(`\n=== ${name} (${key}) — ${r.total} tasks ===`);
    for(const i of r.issues||[]) console.log(" ", i.key, "|", (i.fields.assignee&&i.fields.assignee.displayName)||"-", "|", i.fields.summary.slice(0,80));
  }
})();
