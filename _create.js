const fs=require("fs");
const env=fs.readFileSync(".env","utf8");
const g=k=>{const m=env.match(new RegExp(k+"=(.+)","i"));return m?m[1].trim():null};
const SITE=g("JIRA_SITE"), EMAIL=g("JIRA_EMAIL"), TOKEN=g("JIRA_API_TOKEN");
const auth="Basic "+Buffer.from(EMAIL+":"+TOKEN).toString("base64");
async function j(path,opt){const r=await fetch("https://"+SITE+path,{headers:{Authorization:auth,"Content-Type":"application/json",Accept:"application/json"},...opt});let b;try{b=await r.json()}catch(e){b={}}return {s:r.status,j:b};}

const LOC="712020:5ec38295-3d34-4ff3-ae87-95279adf1dff";
const TRUNG="61bc48ad08e4e00069b20d6c";

function para(text){return {type:"paragraph",content:[{type:"text",text}]};}
function desc(goal, acs, spec){
  const c=[{type:"paragraph",content:[{type:"text",text:"Goal:",marks:[{type:"strong"}]},{type:"text",text:" "+goal}]},
          {type:"paragraph",content:[{type:"text",text:"Acceptance Criteria:",marks:[{type:"strong"}]}]}];
  for(const a of acs) c.push({type:"bulletList",content:[{type:"listItem",content:[{type:"paragraph",content:[{type:"text",text:a}]}]}]});
  c.push({type:"paragraph",content:[{type:"text",text:"Spec Reference:",marks:[{type:"strong"}]},{type:"text",text:" "+spec}]});
  return {type:"doc",version:1,content:c};
}

const tasks=[
 {sum:"[DA-E51-04b] Add Comments On Task (FR 3.6.3)", assignee:LOC,
  goal:"Let Creator/Client/Manager comment on a Task to exchange feedback and request edits directly in the workflow.",
  acs:["Comment textarea with @mention support, image/link attachment.",
       "Comments displayed as timeline with author name + role + timestamp.",
       "POST/GET comments endpoints under /api/v1/workspaces/{id}/tasks/{taskId}/comments."],
  spec:"docs/feature/content-task-workflow/3-6-3-add-comments-on-task/spec.md"},
 {sum:"[DA-E51-05b] Content Writing View (FR 3.6.10)", assignee:TRUNG,
  goal:"Rich-text (Google Docs-style) editor to compose content in-system and auto-convert to correct font on publish, with Content History/Version.",
  acs:["Rich-text editor (bold, italic, list, emoji).",
       "Auto font conversion to correct standard when publishing to social (removes copy-through-Unikey pain).",
       "Content History/Version: track each edit (who/when/diff), allow restore to an old version."],
  spec:"docs/feature/content-task-workflow/3-6-10-content-writting-view/spec.md"}
];

(async()=>{
  for(const t of tasks){
    const body={fields:{
      project:{key:"DA"},
      parent:{key:"DA-939"},
      issuetype:{id:"10045"},
      summary:t.sum,
      assignee:{accountId:t.assignee},
      priority:{name:"Medium"},
      description:desc(t.goal,t.acs,t.spec)
    }};
    const r=await j("/rest/api/3/issue",{method:"POST",body:JSON.stringify(body)});
    console.log(r.s, r.j.key||"", r.j.errorMessages||"", t.sum);
  }
})();
