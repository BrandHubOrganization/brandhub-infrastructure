const fs=require("fs");
const env={}; for(const l of fs.readFileSync(".env","utf8").split(/\r?\n/)){const m=l.match(/^([^#=]+)=(.*)$/); if(m) env[m[1].trim()]=m[2].trim();}
const auth=Buffer.from(`${env.JIRA_EMAIL}:${env.JIRA_API_TOKEN}`).toString("base64");
const H=`https://${env.JIRA_SITE}`;
const AN="712020:b501eda5-2140-417d-bc3a-c942db8310cc";
const tasks=[["DA-1194","E39-01"],["DA-1195","E39-02"],["DA-1196","E39-03"]];
(async()=>{
 for(const [k,id] of tasks){
  const r=await fetch(`${H}/rest/api/3/issue/${k}/assignee`,{method:"PUT",headers:{Authorization:`Basic ${auth}`,"Content-Type":"application/json"},body:JSON.stringify({accountId:AN})});
  console.log((r.status===204?"OK":"FAIL "+r.status),k,id,"-> Ân");
  await new Promise(x=>setTimeout(x,150));
 }
})();
