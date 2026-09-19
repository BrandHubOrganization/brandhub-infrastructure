const fs=require("fs");
const env=fs.readFileSync(".env","utf8");
const g=k=>{const m=env.match(new RegExp(k+"=(.+)","i"));return m?m[1].trim():null};
const SITE=g("JIRA_SITE"), EMAIL=g("JIRA_EMAIL"), TOKEN=g("JIRA_API_TOKEN");
const auth="Basic "+Buffer.from(EMAIL+":"+TOKEN).toString("base64");
async function j(path){const r=await fetch("https://"+SITE+path,{headers:{Authorization:auth,Accept:"application/json"}});return {s:r.status,j:await r.json()};}
(async()=>{
  for(const q of ["Nguyen Thanh Loc","Lê Trí Trung"]){
    const r=await j("/rest/api/3/user/search?query="+encodeURIComponent(q));
    for(const u of (r.j||[])) console.log(JSON.stringify({q, accountId:u.accountId, display:u.displayName}));
  }
})();
