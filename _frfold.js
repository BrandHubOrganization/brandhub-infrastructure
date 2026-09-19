const fs=require("fs");
const {execSync}=require("child_process");
const fr=JSON.parse(fs.readFileSync("_fr_rows.json","utf8"));
const leaf=fr.filter(r=>r.id&&/^\d+\.\d+\.\d+$/.test(r.id));
const csvIds=new Set(leaf.map(r=>r.id));
// list folders, extract FR id "3-4-8" -> "3.4.8"
const out=execSync('find docs/feature -mindepth 2 -maxdepth 2 -type d | grep -v /definition$').toString().trim().split("\n");
const folderIds=new Set();
for(const p of out){const base=p.split("/").pop(); const m=base.match(/^(\d+-\d+-\d+)-/); if(m) folderIds.add(m[1].replace(/-/g,"."));}
console.log("CSV leaf FRs:",csvIds.size);
console.log("folder FR ids:",folderIds.size);
const noFolder=[...csvIds].filter(x=>!folderIds.has(x)).sort((a,b)=>a.localeCompare(b,undefined,{numeric:true}));
const noCsv=[...folderIds].filter(x=>!csvIds.has(x)).sort((a,b)=>a.localeCompare(b,undefined,{numeric:true}));
console.log("\n=== CSV FR KHÔNG có folder ===",noFolder.length);
for(const x of noFolder){const r=leaf.find(y=>y.id===x); console.log("  "+x+" "+r.name);}
console.log("\n=== Folder có FR id KHÔNG trong CSV ===",noCsv.length);
for(const x of noCsv) console.log("  "+x);
