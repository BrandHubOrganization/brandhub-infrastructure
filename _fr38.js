const fs=require("fs");
const {execSync}=require("child_process");
const fr=JSON.parse(fs.readFileSync("_fr_rows.json","utf8"));
const csv=fr.filter(r=>r.id&&r.id.startsWith("3.8")).map(r=>r.id+" "+r.name);
const out=execSync('find docs/feature/publishing-social -mindepth 1 -maxdepth 1 -type d').toString().trim().split("\n");
console.log("=== CSV 3.8.x ==="); for(const c of csv) console.log("  "+c);
console.log("=== folder 3.8.x ==="); for(const p of out) console.log("  "+p.split("/").pop());
