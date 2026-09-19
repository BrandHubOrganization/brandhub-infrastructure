const fs=require("fs");
const fr=JSON.parse(fs.readFileSync("_fr_rows.json","utf8"));
const all=JSON.parse(fs.readFileSync("_all_tasks.json","utf8"));
// leaf FRs from CSV: 3-level id X.Y.Z
const csvFRs=fr.filter(r=>r.id && /^\d+\.\d+\.\d+$/.test(r.id));
console.log("CSV leaf FRs:",csvFRs.length);
// FR ids referenced in any Jira summary
const jiraFRs=new Set();
for(const t of all){
  const m=t.sum.match(/§?(\d+\.\d+\.\d+)/g);
  if(m) for(const x of m) jiraFRs.add(x.replace("§",""));
}
console.log("Jira-referenced 3-level FR ids:",jiraFRs.size);
// missing = CSV FR not referenced in Jira
const missing=csvFRs.filter(r=>!jiraFRs.has(r.id));
console.log("\n=== FR KHÔNG có task (sót) ===",missing.length);
for(const r of missing) console.log("  "+r.id.padEnd(8)+" "+r.name.padEnd(45)+" Code="+(r.code||"-"));
// also: CSV FR with empty Code (no coder assigned)
const noCode=csvFRs.filter(r=>!r.code);
console.log("\n=== FR không có người Code ===",noCode.length);
for(const r of noCode) console.log("  "+r.id.padEnd(8)+" "+r.name);
