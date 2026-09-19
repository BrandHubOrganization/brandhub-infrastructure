const fs=require("fs");
const all=JSON.parse(fs.readFileSync("_all_tasks.json","utf8"));
const fr=JSON.parse(fs.readFileSync("_fr_rows.json","utf8"));
const leaf=fr.filter(r=>r.id&&/^\d+\.\d+\.\d+$/.test(r.id));
const csvIds=new Set(leaf.map(r=>r.id));

// extract FR refs from summaries, expand "FR 3.10.6/7/8" and "§3.2.1"
const frToTask={};
for(const t of all){
  const s=t.sum;
  // pattern: FR 3.10.6/7/8  or  FR 3.10.2  or §3.2.1  or [R3 §3.2.1]
  const m=s.match(/FR\s+(\d+\.\d+(?:\.\d+)?(?:\s*\/\s*\d+(?:\.\d+)*)*)/g);
  if(m){
    for(const grp of m){
      const nums=grp.replace(/^FR\s+/,"").split("/");
      const base=nums[0].trim(); // e.g. "3.10.6"
      const parts=base.split(".");
      for(const n of nums){
        const nn=n.trim();
        const p=nn.split(".");
        if(p.length===3){ if(!frToTask[nn])frToTask[nn]=[]; frToTask[nn].push(t.key); }
        else if(p.length===1){ const full=parts[0]+"."+parts[1]+"."+p[0]; if(!frToTask[full])frToTask[full]=[]; frToTask[full].push(t.key); }
      }
    }
  }
  // §X.Y.Z pattern (D-series doc tasks)
  const m2=s.match(/§(\d+\.\d+\.\d+)/g);
  if(m2){ for(const x of m2){ const id=x.slice(1); if(!frToTask[id])frToTask[id]=[]; frToTask[id].push(t.key); } }
}

const covered=new Set(Object.keys(frToTask));
const missing=[...csvIds].filter(id=>!covered.has(id)).sort((a,b)=>a.localeCompare(b,undefined,{numeric:true}));
console.log("CSV leaf FRs:",csvIds.size);
console.log("FRs with Jira task (summary ref):",covered.size);
console.log("\n=== FR KHÔNG có task trên Jira ===",missing.length);
const byCode={};
for(const id of missing){ const r=leaf.find(x=>x.id===id); const c=r.code||"(no code)"; (byCode[c]=byCode[c]||[]).push(id+" "+r.name); }
for(const c of Object.keys(byCode).sort()){ console.log("\n  ["+c+"]"); for(const x of byCode[c]) console.log("    "+x); }
