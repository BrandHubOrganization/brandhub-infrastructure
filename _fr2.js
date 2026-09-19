const fs=require("fs");
const raw=fs.readFileSync("Các FR của hệ thống  - Feature_Function Requirement.csv","utf8");
function parse(s){const rows=[];let row=[],cur="",q=false;
 for(let i=0;i<s.length;i++){const c=s[i];
  if(q){if(c==='"'){if(s[i+1]==='"'){cur+='"';i++;}else q=false;}else cur+=c;}
  else if(c==='"')q=true;
  else if(c===','){row.push(cur);cur="";}
  else if(c==='\n'||c==='\r'){if(c==='\r'&&s[i+1]==='\n')i++; row.push(cur);rows.push(row);row=[];cur="";}
  else cur+=c;}
 if(cur.length||row.length){row.push(cur);rows.push(row);}
 return rows;}
const rows=parse(raw);
const h=rows[0].map(x=>x.trim());
console.log("header:",JSON.stringify(h));
const data=rows.slice(1);
const leaf=data.filter(r=>/^\d+\.\d+\.\d+$/.test((r[0]||"").trim()));
console.log("leaf FRs:",leaf.length);
const hd={}; h.forEach((x,i)=>hd[x]=i);
const statusDist={}; for(const r of leaf){const s=(r[hd["Hiện trạng"]]||"").trim()||"(empty)"; statusDist[s]=(statusDist[s]||0)+1;}
console.log("Hiện trạng dist:",JSON.stringify(statusDist));
const doneDist={}; for(const r of leaf){const s=(r[hd["Đã thực hiện xong tài liệu "]]||"").trim()||"(empty)"; doneDist[s]=(doneDist[s]||0)+1;}
console.log("Đã xong tài liệu dist:",JSON.stringify(doneDist));
