const fs=require("fs");
const env=fs.readFileSync(".env","utf8");
const g=k=>{const m=env.match(new RegExp(k+"=(.+)","i"));return m?m[1].trim():null};
const SITE=g("JIRA_SITE"), EMAIL=g("JIRA_EMAIL"), TOKEN=g("JIRA_API_TOKEN");
const auth="Basic "+Buffer.from(EMAIL+":"+TOKEN).toString("base64");
async function j(path){const r=await fetch("https://"+SITE+path,{headers:{Authorization:auth,Accept:"application/json"}});return {s:r.status,j:await r.json()};}
(async()=>{
  // description ADF of DA-980
  const r=await j("/rest/api/3/issue/DA-980?fields=description");
  console.log("DESC:", JSON.stringify(r.j.fields.description).slice(0,500));
  // create metadata
  const m=await j("/rest/api/3/issue/createmeta?projectKeys=DA&expand=projects.issuetypes.fields");
  const p=m.j.projects&&m.j.projects[0];
  console.log("project:", p.key, p.name);
  for(const it of p.issuetypes){
    if(it.name==="Task"){
      console.log("Task type id:", it.id, "untanslated:", it.untranslatedKey);
      // find parent + epic fields
      const keys=Object.keys(it.fields||{});
      console.log("fields:", keys.filter(k=>/parent|epic|Epic/i.test(k)).map(k=>k+"="+(it.fields[k].name||it.fields[k].key)));
    }
  }
})();
