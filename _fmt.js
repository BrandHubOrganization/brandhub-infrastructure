const fs=require("fs");
const env=fs.readFileSync(".env","utf8");
const g=k=>{const m=env.match(new RegExp(k+"=(.+)","i"));return m?m[1].trim():null};
const SITE=g("JIRA_SITE"), EMAIL=g("JIRA_EMAIL"), TOKEN=g("JIRA_API_TOKEN");
const auth="Basic "+Buffer.from(EMAIL+":"+TOKEN).toString("base64");
async function j(path){const r=await fetch("https://"+SITE+path,{headers:{Authorization:auth,Accept:"application/json"}});return {s:r.status,j:await r.json()};}
(async()=>{
  const r=await j("/rest/api/3/issue/DA-980?fields=summary,description,priority,labels,customfield_10014,customfield_10015,parent,issuetype");
  console.log("status",r.s);
  const f=r.j.fields;
  console.log("priority:",f.priority&&f.priority.name);
  console.log("parent:",JSON.stringify(f.parent&&{key:f.parent.key,type:f.parent.fields&&f.parent.fields.issuetype&&f.parent.fields.issuetype.name}));
  console.log("labels:",JSON.stringify(f.labels));
  console.log("--- description ---");
  console.log((f.description||"").slice(0,600));
})();
