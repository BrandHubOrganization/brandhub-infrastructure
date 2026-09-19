const fs=require("fs");
const env=fs.readFileSync(".env","utf8");
const g=k=>{const m=env.match(new RegExp(k+"=(.+)","i"));return m?m[1].trim():null};
const SITE=g("JIRA_SITE"), EMAIL=g("JIRA_EMAIL"), TOKEN=g("JIRA_API_TOKEN");
const auth="Basic "+Buffer.from(EMAIL+":"+TOKEN).toString("base64");
async function j(p){const r=await fetch("https://"+SITE+p,{headers:{Authorization:auth,Accept:"application/json"}});return {s:r.status,j:await r.json()};}
(async()=>{
  // find AI epic
  const e=await j("/rest/api/3/search/jql?jql="+encodeURIComponent('project=DA AND issuetype=Epic ORDER BY key ASC')+"&maxResults=100&fields=summary,key");
  console.log("=== EPICS ===");
  for(const i of e.j.issues||[]) console.log(i.key, "|", i.fields.summary);
  // user an
  const u=await j("/rest/api/3/user/search?query="+encodeURIComponent("ân"));
  console.log("=== ân ===");
  for(const x of u.j||[]) console.log(x.accountId, "|", x.displayName);
})();
