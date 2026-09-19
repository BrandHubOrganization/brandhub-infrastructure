const fs=require("fs");
const env=fs.readFileSync(".env","utf8");
const g=k=>{const m=env.match(new RegExp(k+"=(.+)","i"));return m?m[1].trim():null};
const SITE=g("JIRA_SITE"), EMAIL=g("JIRA_EMAIL"), TOKEN=g("JIRA_API_TOKEN");
const auth="Basic "+Buffer.from(EMAIL+":"+TOKEN).toString("base64");
async function j(p){const r=await fetch("https://"+SITE+p,{headers:{Authorization:auth,Accept:"application/json"}});return await r.json();}
(async()=>{
  for(let k=1238;k<=1249;k++){
    const i=await j("/rest/api/3/issue/DA-"+k+"?fields=summary,assignee,parent");
    const f=i.fields;
    console.log("DA-"+k, "|", f.summary, "|", f.assignee&&f.assignee.displayName, "|", f.parent&&f.parent.key);
  }
})();
