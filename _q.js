const fs=require("fs");
const all=JSON.parse(fs.readFileSync("_all_tasks.json","utf8"));
const st=JSON.parse(fs.readFileSync("_status.json","utf8"));
const ids=["E50","E16","E17","E52","E13","E14","E010","E01"];
function bid(s){const m=s.match(/\[(DA-(E\d+)-(\d+))\s*\]/); return m?{full:m[1],epic:m[2],num:m[3]}:null;}
const out=all.filter(t=>{const b=bid(t.sum); return b && ids.includes(b.epic);});
console.log("range-expansion tasks:",out.length);
out.sort((a,b)=>(bid(a.sum)?.epic||"").localeCompare(bid(b.sum)?.epic||"")||(bid(a.sum)?.num||"")- (bid(b.sum)?.num||""));
for(const t of out){
  const b=bid(t.sum); const s=st[t.key];
  console.log(t.key.padEnd(8)+" "+b.full.padEnd(11)+" ass="+(t.ass||"UNASSIGNED").padEnd(22)+" status="+(s?s.status:"?"));
}
