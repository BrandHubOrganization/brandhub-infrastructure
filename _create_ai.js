const fs=require("fs");
const env=fs.readFileSync(".env","utf8");
const g=k=>{const m=env.match(new RegExp(k+"=(.+)","i"));return m?m[1].trim():null};
const SITE=g("JIRA_SITE"), EMAIL=g("JIRA_EMAIL"), TOKEN=g("JIRA_API_TOKEN");
const auth="Basic "+Buffer.from(EMAIL+":"+TOKEN).toString("base64");
async function j(path,opt){const r=await fetch("https://"+SITE+path,{headers:{Authorization:auth,"Content-Type":"application/json",Accept:"application/json"},...opt});let b;try{b=await r.json()}catch(e){b={}}return {s:r.status,j:b};}

const A="712020:b501eda5-2140-417d-bc3a-c942db8310cc"; // Ân
const T="712020:198f8574-4327-4e82-8674-275f3b950db0"; // Tuấn
const L="712020:5ec38295-3d34-4ff3-ae87-95279adf1dff"; // Lộc

function desc(goal, spec){
  return {type:"doc",version:1,content:[
    {type:"paragraph",content:[{type:"text",text:"Goal:",marks:[{type:"strong"}]},{type:"text",text:" "+goal}]},
    {type:"paragraph",content:[{type:"text",text:"Spec Reference:",marks:[{type:"strong"}]},{type:"text",text:" "+spec}]}
  ]};
}

// FR, name, epic key, assignee, goal
const tasks=[
 ["3.7.1","View Trending Topics Suggestions","DA-98",A,"Let Creator view current trending keywords to create viral, on-trend content."],
 ["3.7.2","Generate Caption","DA-79",A,"Let Creator use AI to generate post captions, saving writing time."],
 ["3.7.3","Generate Ambassador","DA-99",T,"Let Creator create a virtual AI Ambassador to represent the brand before a real model exists."],
 ["3.7.4","View Image Style Template","DA-97",L,"Let Creator pick a preset image style template to generate images in a desired style faster."],
 ["3.7.5","Generate Image","DA-97",L,"Let Creator use AI to generate post images without manual shooting/design."],
 ["3.7.6","View Video Style Template","DA-110",A,"Let Creator pick a preset video style template to generate videos in a desired style faster."],
 ["3.7.7","Generate Video","DA-110",A,"Let Creator use AI to generate video content without manual filming/editing."],
 ["3.7.8","Export File","DA-111",T,"Let Creator export generated files to local for storage or manual upload to another social platform."],
 ["3.7.9","Crawl Schedule Config","DA-98",A,"Let Admin configure the trend crawl schedule to control system resources and trend-data quality."],
 ["3.7.10","Suggest hashtag trend","DA-98",T,"Let Creator get AI-suggested trending hashtags relevant to their content."],
 ["3.7.11","Generate Livestream Script","DA-79",L,"Let Creator use AI to generate a livestream script template as a starting point."],
 ["3.7.12","Recommend Collaborator","DA-79",L,"Let Creator/Manager get AI-recommended media partners to expand campaigns beyond social media."]
];

(async()=>{
  for(const [fr,name,epic,ass,goal] of tasks){
    const folder=name.toLowerCase().replace(/[^a-z0-9]+/g,"-");
    const spec="docs/feature/ai-features/"+fr+"-"+folder+"/spec.md";
    const body={fields:{
      project:{key:"DA"},
      parent:{key:epic},
      issuetype:{id:"10045"},
      summary:"[FR "+fr+"] "+name,
      assignee:{accountId:ass},
      priority:{name:"Medium"},
      description:desc(goal,spec)
    }};
    const r=await j("/rest/api/3/issue",{method:"POST",body:JSON.stringify(body)});
    console.log(r.s, r.j.key||"-", "|", fr, name, "|", (r.j.errorMessages||[]).join(" "));
  }
})();
