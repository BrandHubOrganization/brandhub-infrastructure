# DA-AI04-99-01 — Phân tích và Thiết kế Tầng Thu thập Dữ liệu

**Epic:** AI-4.99 — Analyze deeply crawl trend flow
**Task ID:** DA-AI04-99-01
**Assignee:** Tuấn (Crawl)
**Priority:** 🔴 High
**Status:** Research Complete (Revised — MVP API-first strategy)
**Date:** 2026-08-03

---

## Mục lục

1. [Tổng quan & Chiến lược MVP](#1-tổng-quan--chiến-lược-mvp)
2. [Google Trends Crawler](#2-google-trends-crawler)
3. [TikTok Crawler — Creative Center & KOL Feed](#3-tiktok-crawler--creative-center--kol-feed)
4. [Facebook Public Groups Scraper](#4-facebook-public-groups-scraper)
5. [Chiến lược Chống chặn (Anti-Blocking)](#5-chiến-lược-chống-chặn-anti-blocking)
6. [APScheduler — Cơ chế Lập lịch](#6-apscheduler--cơ-chế-lập-lịch)
7. [Tầng Lưu trữ Đệm Thô (Raw Storage Buffer)](#7-tầng-lưu-trữ-đệm-thô-raw-storage-buffer)
8. [Kiến trúc Tổng thể & Luồng Dữ liệu](#8-kiến-trúc-tổng-thể--luồng-dữ-liệu)
9. [Acceptance Criteria Checklist](#9-acceptance-criteria-checklist)
10. [Dependencies & Next Steps](#10-dependencies--next-steps)

---

## 1. Tổng quan & Chiến lược MVP

### 1.1 Triết lý: API-first, code sau

**MVP dùng third-party API đã có sẵn. Không tự code crawler từ đầu.**

Lý do:
- Tự code crawler chống anti-bot (đặc biệt TikTok) tốn hàng tuần debug, block rate vẫn 14-22%.
- Apify, ScrapeCreators đã giải quyết bài toán proxy, session, anti-detection — trả về JSON sạch.
- MVP cần data nhanh để unblock DA-AI04-99-02 (BM25 Engine). Crawler chất lượng production làm sau khi có user feedback.
- Chi phí API thấp hơn nhiều so với công sức dev + maintenance liên tục.

**Lộ trình:**
```
Giai đoạn 1 (MVP - now):     API bên thứ 3 (Apify + ScrapeCreators + SerpApi)
                                → Data flow chạy được trong 1-2 tuần
Giai đoạn 2 (Scale - later):  Tự code crawler chọn lọc (chỉ source nào API quá đắt)
                                → Giảm chi phí, tăng control
```

### 1.2 So sánh nền tảng

| Tiêu chí | Apify | ScrapeCreators | Tự code (cũ) |
|---|---|---|---|
| **TikTok** | `clockworks/tiktok-scraper` — 228K users, 4.8★, $1.70/1K results | 22 endpoints (profile, hashtag, trending feed, video), $47/tháng (25K credits) | Playwright+stealth, block 14-22%, tốn tuần debug |
| **Facebook** | `danek/facebook-search-ppr` — 5.8K users, 4.6★, search results | 11 endpoints (không rõ group support) | Scrapy+proxy, phải maintain selector |
| **Google Trends** | Không có actor chuyên dụng | Không có endpoint Google Trends rõ ràng | pytrends đã chết |
| **Google Trends (thực tế)** | N/A | N/A | **→ SerpApi / DataForSEO** (API chuyên biệt) |
| **Pricing model** | Pay-per-event ($1-5/1K results) | Subscription ($47-497/tháng) | Free code + proxy cost ($3-50/tháng) |
| **Maintenance** | Không cần — actor tự update | Không cần — API tự update | Cao — selector vỡ mỗi khi platform đổi DOM |
| **Time to market** | 1-2 ngày (gọi API) | 1-2 ngày (gọi API) | 2-4 tuần (code + test + debug anti-bot) |

### 1.3 Nguồn dữ liệu & Công cụ (MVP)

| Nguồn | Loại dữ liệu | Tần suất | MVP Tool | Fallback |
|---|---|---|---|---|
| Google Trends | Trending keywords VN | Mỗi 6h | **SerpApi** Google Trends API | DataForSEO |
| TikTok — hashtag trending | Hashtag hot, top search | Mỗi 6h | **ScrapeCreators** TikTok API (`/v1/tiktok/get-trending-feed`, `/v1/tiktok/search/hashtag`) | Apify TikTok Scraper |
| TikTok — KOL feed | Bài đăng + comments KOL | Mỗi 6h | **Apify** TikTok Scraper (`clockworks/tiktok-scraper`) | ScrapeCreators `/v3/tiktok/profile/videos` |
| Facebook Public Groups | Bài đăng + comments | Mỗi 6h | **Apify** Facebook Search Scraper (`danek/facebook-search-ppr`) | ScrapeCreators Facebook API |

### 1.4 Tổng chi phí MVP ước tính

| Dịch vụ | Plan | Chi phí/tháng |
|---|---|---|
| SerpApi | Free (100 searches) hoặc Starter $50 | $0 - $50 |
| Apify TikTok Scraper | ~4 calls/ngày × 30 ngày = 120 calls, ~$5 | ~$5 |
| ScrapeCreators | Free (100 credits) hoặc Freelance $47 | $0 - $47 |
| Apify Facebook Search | ~4 calls/ngày × 30 ngày, ~$3 | ~$3 |
| **Tổng (dùng free tier + 1 paid)** | | **$0 - $55/tháng** |

So với tự code: 2-4 tuần dev time (cost cao hơn nhiều) + $3-50/tháng proxy + maintenance liên tục. API-first tiết kiệm ít nhất 80% thời gian MVP.

### 1.5 pytrends status

**pytrends đã chết.** Archived trên GitHub từ tháng 4/2025. Google thay đổi session auth flow — mọi request đều trả về 429. Không có cách fix từ phía client. SerpApi là replacement tốt nhất cho Google Trends data.

---

## 2. Google Trends Crawler

### 2.1 Bối cảnh

Google Trends không có official public API. Không có actor trên Apify Store, không có endpoint trên ScrapeCreators cho Google Trends. Giải pháp: dùng API chuyên biệt của bên thứ 3 đã giải quyết bài toán session + parse.

**Lựa chọn MVP: SerpApi Google Trends API** — ổn định nhất, trả JSON sạch, không cần quản lý session/proxy.

### 2.2 Cấu hình khu vực và tham số

```python
# Cấu hình đề xuất cho BrandHub
TRENDS_CONFIG = {
    "geo": "VN",                    # Vietnam
    "timeframe": "now 7-d",         # Cửa sổ 7 ngày gần nhất
    "hl": "vi",                     # Ngôn ngữ tiếng Việt
    "category": 0,                  # 0 = tất cả categories
    "property": "",                 # Web Search (mặc định); có thể đổi sang YouTube/News
}

# Category ID quan trọng cho BrandHub:
#   71  - Food & Drink
#   533 - Beauty & Fitness
#   18  - Fashion & Style
#   180 - Travel
#   48  - Entertainment
```

### 2.3 Giới hạn & Rate Limits

| Giới hạn | Mô tả |
|---|---|
| Max keywords/batch | 5 từ khóa (cùng chia sẻ scale 0-100) |
| Realtime trending | `realtime_trending_searches(pn='VN')` — tối đa ~50 results/lần gọi |
| Rate limit (pytrends raw) | ~50 requests/ngày trước khi bị 429 |
| Rate limit (SerpApi) | 100 searches/tháng (free), 1,000+/tháng (paid $50) |
| Rate limit (DataForSEO) | Không giới hạn, tính phí theo request |
| Dữ liệu historical | Tối đa 5 năm (với official API alpha) |

### 2.4 Giải pháp triển khai

**Primary: SerpApi Google Trends API**

```python
# brandhub-ai-service/app/services/crawlers/google_trends.py

from serpapi import GoogleSearch
from app.core.config import settings

async def fetch_trending_searches(geo: str = "VN") -> list[dict]:
    """Lấy danh sách trending searches từ Google Trends qua SerpApi."""
    params = {
        "api_key": settings.serpapi_api_key,
        "engine": "google_trends_trending_now",
        "geo": geo,
        "hl": "vi",
        "hours": 6,              # Lấy trending trong 6h gần nhất
    }
    search = GoogleSearch(params)
    results = search.get_dict()

    # Chuẩn hóa về format chung
    trends = []
    for item in results.get("trending_searches", []):
        trends.append({
            "source": "google_trends",
            "keyword": item["query"],
            "traffic_breakdown": item.get("trend_breakdown", []),
            "related_queries": [q["query"] for q in item.get("related_queries", [])],
            "published_date": item.get("date"),
            "articles": item.get("articles", [])[:5],  # Top 5 bài báo liên quan
        })
    return trends
```

**Fallback: DataForSEO**

```python
# Dùng khi cần batch query hoặc SerpApi hết quota
async def fetch_trends_via_dataforseo(keywords: list[str], geo: str = "VN"):
    """Fallback: DataForSEO Google Trends API."""
    payload = [{
        "keywords": keywords,
        "location_code": 2704,   # Vietnam
        "time_range": "past_7_days",
        "language_code": "vi",
    }]
    # POST https://api.dataforseo.com/v3/keywords_data/google_trends/explore/live
    # ...
```

### 2.5 Dependency mới cần thêm

```
# requirements.txt
serpapi==0.1.5              # Google Trends qua SerpApi (MVP — không có trên Apify/ScrapeCreators)
# Backup: google-trends-api==1.0.0  # DataForSEO SDK
```

---

## 3. TikTok Crawler — Creative Center & KOL Feed

### 3.1 Bối cảnh

TikTok anti-bot defense cực mạnh: TLS fingerprint (JA3/JA4), TTWID cookie, msToken crypto, WebGL check, behavioral analysis. Tự code Playwright+stealth vẫn bị block 14-22%. **MVP không nên tự code — dùng API đã giải quyết bài toán này.**

### 3.2 Giải pháp MVP: API-first, 3 tầng

```
                ┌──────────────────────────────────────┐
                │   Tầng 1: Third-party API (primary)   │
                │   • Apify TikTok Scraper (KOL feed)   │
                │   • ScrapeCreators TikTok API (trend)  │
                │   → JSON sạch, zero anti-bot headache  │
                └──────────┬───────────────────────────┘
                           │ fallback khi hết quota/API down
                ┌──────────▼───────────────────────────┐
                │   Tầng 2: Custom Playwright (later)   │
                │   Chỉ build khi scale, không cho MVP   │
                └──────────┬───────────────────────────┘
                           │ fallback cuối cùng
                ┌──────────▼───────────────────────────┐
                │   Tầng 3: Seed List tĩnh              │
                │   Luôn hoạt động, không phụ thuộc API   │
                └──────────────────────────────────────┘
```

### 3.3 Tầng 1A: ScrapeCreators TikTok API (Trending + Hashtag)

Nền tảng: https://scrapecreators.com/tiktok-api — 22 endpoints, subscription model.

**Endpoints quan trọng cho BrandHub:**

| Endpoint | Path | Dùng cho |
|---|---|---|
| Trending Feed | `GET /v1/tiktok/get-trending-feed` | Lấy video đang trending (thay thế Creative Center) |
| Search by Hashtag | `GET /v1/tiktok/search/hashtag` | Lấy video theo hashtag cụ thể |
| Top Search | `GET /v1/tiktok/search/top` | Top search queries (≈ trending topics) |
| Popular Creators | `GET /v1/tiktok/creators/popular` | Danh sách KOL đang hot |
| Search by Keyword | `GET /v1/tiktok/search/keyword` | Tìm video theo keyword |
| Profile Videos | `GET /v3/tiktok/profile/videos` | Lấy toàn bộ video của 1 user |

**Pricing:**
- Free: 100 credits/tháng
- Freelance: $47/tháng (25,000 credits, $1.88/1K)
- Business: $497/tháng (500,000 credits, $0.99/1K)
- Credits không hết hạn, cached results = 0 credits.

**MVP: Free tier (test) → Freelance $47/tháng khi cần scale.**

```python
# brandhub-ai-service/app/services/crawlers/tiktok_scrapecreators.py

import httpx
from app.core.config import settings

SCRAPECREATORS_BASE = "https://api.scrapecreators.com"

async def fetch_trending_feed(region: str = "VN", count: int = 20) -> list[dict]:
    """Lấy trending feed TikTok qua ScrapeCreators API."""
    async with httpx.AsyncClient(timeout=30.0) as client:
        response = await client.get(
            f"{SCRAPECREATORS_BASE}/v1/tiktok/get-trending-feed",
            params={"region": region, "count": count},
            headers={
                "Authorization": f"Bearer {settings.scrapecreators_api_key}",
                "Content-Type": "application/json",
            },
        )
        response.raise_for_status()
        data = response.json()
        return _normalize_trending(data)

async def fetch_hashtag_videos(hashtag: str, count: int = 20) -> list[dict]:
    """Tìm video theo hashtag."""
    async with httpx.AsyncClient(timeout=30.0) as client:
        response = await client.get(
            f"{SCRAPECREATORS_BASE}/v1/tiktok/search/hashtag",
            params={"keyword": hashtag, "count": count},
            headers={"Authorization": f"Bearer {settings.scrapecreators_api_key}"},
        )
        response.raise_for_status()
        return response.json()

async def fetch_top_searches(region: str = "VN") -> list[dict]:
    """Lấy danh sách top search queries — nguồn trending keyword."""
    async with httpx.AsyncClient(timeout=30.0) as client:
        response = await client.get(
            f"{SCRAPECREATORS_BASE}/v1/tiktok/search/top",
            params={"region": region},
            headers={"Authorization": f"Bearer {settings.scrapecreators_api_key}"},
        )
        response.raise_for_status()
        return response.json()

async def fetch_popular_creators(region: str = "VN", count: int = 50) -> list[dict]:
    """Lấy danh sách creator đang hot — dùng để cập nhật KOL seed list."""
    async with httpx.AsyncClient(timeout=30.0) as client:
        response = await client.get(
            f"{SCRAPECREATORS_BASE}/v1/tiktok/creators/popular",
            params={"region": region, "count": count},
            headers={"Authorization": f"Bearer {settings.scrapecreators_api_key}"},
        )
        response.raise_for_status()
        return response.json()
```

### 3.4 Tầng 1B: Apify TikTok Scraper (KOL Feed + Deep Profile)

Actor: https://apify.com/clockworks/tiktok-scraper — 228K users, 4.8★ (339 reviews).

**Tính năng:**
- Scrape profile, hashtag, video, user data từ URL hoặc search query
- Hỗ trợ video download, subtitle/transcription (tính thêm phí)
- Export JSON/CSV qua API, scheduling, webhook
- Pay-per-event: **từ $1.70 / 1,000 results**

**Dùng cho:** Lấy toàn bộ feed của KOL cụ thể (những KOL đã xác định trong seed list). ScrapeCreators cũng có profile videos endpoint, nhưng Apify rẻ hơn cho volume lớn và có thêm transcription.

```python
# brandhub-ai-service/app/services/crawlers/tiktok_apify.py

import httpx
import asyncio
from app.core.config import settings

APIFY_BASE = "https://api.apify.com/v2"

async def run_tiktok_scraper(
    usernames: list[str],
    results_per_profile: int = 10,
) -> list[dict]:
    """
    Chạy Apify TikTok Scraper actor cho danh sách KOL.

    Input: profile URLs hoặc usernames
    Output: posts[], có thể include comments, hashtags, music info
    """
    actor_id = "clockworks/tiktok-scraper"

    # Construct input for the actor
    input_data = {
        "profileUrls": [f"https://www.tiktok.com/@{u}" for u in usernames],
        "resultsPerPage": results_per_profile,
        "shouldDownloadVideos": False,       # Không cần video binary
        "shouldDownloadCovers": False,
        "shouldDownloadSubtitles": False,    # Bật nếu cần transcript (thêm phí)
    }

    # 1. Start actor run
    async with httpx.AsyncClient(timeout=60.0) as client:
        run_response = await client.post(
            f"{APIFY_BASE}/acts/{actor_id}/runs",
            params={"token": settings.apify_api_token},
            json=input_data,
        )
        run_response.raise_for_status()
        run_data = run_response.json()
        run_id = run_data["data"]["id"]

        # 2. Poll until complete (Apify webhook pattern cũng có thể dùng)
        while True:
            status_response = await client.get(
                f"{APIFY_BASE}/acts/{actor_id}/runs/{run_id}",
                params={"token": settings.apify_api_token},
            )
            status_data = status_response.json()
            status = status_data["data"]["status"]
            if status == "SUCCEEDED":
                break
            if status in ("FAILED", "ABORTED", "TIMED-OUT"):
                raise Exception(f"Apify actor run {status}: {run_id}")
            await asyncio.sleep(10)  # Poll mỗi 10s

        # 3. Fetch results từ default dataset
        dataset_id = status_data["data"]["defaultDatasetId"]
        results_response = await client.get(
            f"{APIFY_BASE}/datasets/{dataset_id}/items",
            params={"token": settings.apify_api_token, "format": "json"},
        )
        return results_response.json()

async def fetch_kol_feed_apify(kol_usernames: list[str]) -> list[dict]:
    """Wrapper: Apify TikTok Scraper → normalized output."""
    raw_posts = await run_tiktok_scraper(kol_usernames, results_per_profile=10)
    return [_normalize_apify_post(p) for p in raw_posts]
```

**Pricing ước tính (MVP):**
- Mỗi lần crawl: 50 KOLs × 10 posts = 500 results
- 4 lần/ngày × 30 ngày = 60,000 results/tháng
- $1.70/1K × 60 = ~$102/tháng (nếu dùng Apify toàn bộ)
- **Tối ưu:** Dùng ScrapeCreators cho trending (đã bao gồm trong subscription), Apify chỉ cho KOL feed → giảm còn ~$5-10/tháng

### 3.5 Tầng 2: Custom Playwright (Dự phòng xa — không build trong MVP)

Chỉ triển khai Tầng 2 khi:
- Apify/ScrapeCreators cùng down (hiếm)
- Chi phí API vượt ngân sách → cần tự code để giảm cost
- Cần data không có trong API (ví dụ: live stream comments)

Code mẫu giữ lại từ thiết kế cũ (Section 3.4 bản gốc) — tham khảo khi cần.

<details>
<summary>Playwright + pw-stealth-enhanced (click để mở)</summary>

```python
# Chỉ triển khai khi API third-party không đáp ứng được
# Block rate dự kiến: 14-22%, cần headed mode + residential proxy

import asyncio, random
from playwright.async_api import async_playwright
from pw_stealth_enhanced import Stealth

async def scrape_creative_center_hashtags_fallback() -> list[dict]:
    """Fallback xa: Dùng Playwright headed cào TikTok Creative Center."""
    async with Stealth().use_async(async_playwright()) as p:
        browser = await p.chromium.launch(
            headless=False,
            args=["--disable-blink-features=AutomationControlled"],
        )
        context = await browser.new_context(
            user_agent=random.choice(USER_AGENTS_MOBILE),
            viewport={"width": 390, "height": 844},
            locale="vi-VN",
            timezone_id="Asia/Ho_Chi_Minh",
        )
        page = await context.new_page()
        await page.goto("https://ads.tiktok.com/business/creativecenter/hashtag/trending")
        await page.wait_for_timeout(random.randint(2000, 4000))

        for _ in range(3):
            await page.evaluate("window.scrollBy(0, 300)")
            await page.wait_for_timeout(random.randint(800, 1500))

        hashtags = await page.evaluate("""() => {
            const items = document.querySelectorAll('[class*="hashtag"]');
            return Array.from(items).map(el => ({
                tag: el.textContent.trim(),
                views: el.querySelector('[class*="count"]')?.textContent || '',
            }));
        }""")
        await browser.close()
    return hashtags
```
</details>

### 3.6 Tầng 3: Seed List tĩnh (Luôn hoạt động)

```python
# Danh sách KOL mục tiêu — seed ban đầu, cập nhật từ ScrapeCreators /popular/creators
TARGETED_KOLS = {
    "tiktok": [
        {"username": "ninheating", "category": "food_review", "followers": "2.3M"},
        {"username": "honeymilktea.vn", "category": "food_review", "followers": "850K"},
        # ... 50-100 KOLs, update hàng tuần từ API popular creators
    ],
}
```

### 3.7 Chuẩn hóa Output

Giữ nguyên schema từ thiết kế cũ. Cả Apify và ScrapeCreators output được normalize về format này:

```json
{
    "source": "tiktok",
    "crawl_time": "2026-08-03T20:00:00Z",
    "posts": [
        {
            "post_id": "tt_738291038102",
            "author": "ninheating",
            "platform": "tiktok",
            "content": "...",
            "hashtags": ["trasuadatnung", "reviewdoan"],
            "media_type": "video",
            "interactions": {
                "likes": 45000,
                "shares": 1200,
                "comments_count": 850,
                "plays": 1200000
            },
            "crawled_at": "2026-08-03T20:00:00Z"
        }
    ]
}
```

### 3.8 Dependency mới cần thêm

```
# requirements.txt
httpx==0.28.1                       # Đã có — dùng gọi cả Apify + ScrapeCreators API
# Không cần playwright, scrapy, pw-stealth-enhanced trong MVP
```

---

## 4. Facebook Public Groups Scraper

### 4.1 Bối cảnh

Facebook không có public API để đọc bài viết từ group. Cả Apify và ScrapeCreators đều có Facebook-related actors/endpoints nhưng **không có actor chuyên biệt cho group scraping**. Các option:

| Option | Coverage | Risk |
|---|---|---|
| **Apify Facebook Search Scraper** (`danek/facebook-search-ppr`) | Search Facebook content — có thể search trong group nếu query đúng | Có thể không cover hết group posts |
| **ScrapeCreators Facebook API** | 11 endpoints, không rõ group support | Cần test trial |
| **Custom Scrapy + Proxy** (cũ) | Toàn quyền kiểm soát | Tốn công build + maintain |

**Quyết định MVP:** Bắt đầu với Apify Facebook Search Scraper. Nếu không cover group đủ, fallback sang ScrapeCreators. Nếu cả hai đều không đáp ứng, mới build Scrapy spider.

### 4.2 Giải pháp MVP: Apify Facebook Search Scraper

Actor: https://apify.com/danek/facebook-search-ppr — 5.8K users, 4.6★ (16 reviews).

```python
# brandhub-ai-service/app/services/crawlers/facebook_apify.py

import httpx
import asyncio
from datetime import datetime
from app.core.config import settings

APIFY_BASE = "https://api.apify.com/v2"

async def search_facebook_groups(
    search_terms: list[str],
    max_results: int = 50,
) -> list[dict]:
    """
    Tìm bài viết Facebook theo keyword (bao gồm group content).

    Dùng Apify Facebook Search Scraper actor.
    Search terms ví dụ: ["trà sữa Hà Nội", "review quán ăn Sài Gòn", ...]
    """
    actor_id = "danek/facebook-search-ppr"

    input_data = {
        "searchTerms": search_terms,
        "maxResults": max_results,
        "proxyConfiguration": {
            "useApifyProxy": True,  # Apify tự quản lý proxy
        },
    }

    async with httpx.AsyncClient(timeout=120.0) as client:
        # Start actor
        run_resp = await client.post(
            f"{APIFY_BASE}/acts/{actor_id}/runs",
            params={"token": settings.apify_api_token},
            json=input_data,
        )
        run_resp.raise_for_status()
        run_id = run_resp.json()["data"]["id"]

        # Poll until done
        for _ in range(60):  # Max 10 min poll
            status_resp = await client.get(
                f"{APIFY_BASE}/acts/{actor_id}/runs/{run_id}",
                params={"token": settings.apify_api_token},
            )
            status = status_resp.json()["data"]["status"]
            if status == "SUCCEEDED":
                break
            if status in ("FAILED", "ABORTED", "TIMED-OUT"):
                raise Exception(f"Apify FB search failed: {run_id}")
            await asyncio.sleep(10)

        # Fetch results
        dataset_id = status_resp.json()["data"]["defaultDatasetId"]
        results = await client.get(
            f"{APIFY_BASE}/datasets/{dataset_id}/items",
            params={"token": settings.apify_api_token, "format": "json"},
        )
        return results.json()

def _normalize_fb_apify(raw_posts: list[dict]) -> list[dict]:
    """Chuẩn hóa output từ Apify Facebook Search → schema chung."""
    normalized = []
    for post in raw_posts:
        normalized.append({
            "source": "facebook",
            "post_id": post.get("id", ""),
            "author": post.get("author", {}).get("name", "unknown"),
            "content": post.get("text", ""),
            "hashtags": post.get("hashtags", []),
            "url": post.get("url", ""),
            "timestamp": post.get("timestamp", ""),
            "interactions": {
                "likes": post.get("likes", 0),
                "comments_count": post.get("comments", 0),
                "shares": post.get("shares", 0),
            },
            "crawled_at": datetime.utcnow().isoformat(),
        })
    return normalized
```

### 4.3 Fallback: ScrapeCreators Facebook API

https://scrapecreators.com/facebook-api — 11 endpoints.

```python
# brandhub-ai-service/app/services/crawlers/facebook_scrapecreators.py

SCRAPECREATORS_BASE = "https://api.scrapecreators.com"

async def search_facebook_scrapecreators(keyword: str, count: int = 50) -> list[dict]:
    """Fallback: ScrapeCreators Facebook search."""
    async with httpx.AsyncClient(timeout=30.0) as client:
        response = await client.get(
            f"{SCRAPECREATORS_BASE}/v1/facebook/search",
            params={"keyword": keyword, "count": count},
            headers={"Authorization": f"Bearer {settings.scrapecreators_api_key}"},
        )
        response.raise_for_status()
        return response.json()
```

### 4.4 Fallback xa: Custom Scrapy Spider (không build trong MVP)

Chỉ build khi:
- Cả Apify và ScrapeCreators đều không cover được group content
- Cần data đặc thù không có trong API (VD: tất cả comments của 1 post)

Code Scrapy spider giữ lại từ thiết kế cũ trong file appendix (không include trong MVP codebase).

### 4.5 Dependency mới cần thêm

```
# requirements.txt
httpx==0.28.1           # Đã có — dùng gọi Apify + ScrapeCreators API
# Không cần scrapy, scrapy-fake-useragent, scrapy-rotating-proxies trong MVP
```

---

## 5. Chiến lược Chống chặn (Anti-Blocking)

### 5.1 MVP: API handles it

Với API-first approach, Apify và ScrapeCreators tự quản lý:
- Proxy rotation (residential + datacenter pool)
- Session management (cookie, token refresh)
- TLS fingerprint matching
- Rate limit handling (exponential backoff, queue)
- User-Agent rotation
- CAPTCHA solving (nếu cần)

**BrandHub chỉ cần:** request throttling phía client để không spam API (tránh bị ban key).

### 5.2 Request Throttler (giữ lại từ thiết kế cũ)

```python
# brandhub-ai-service/app/services/crawlers/throttler.py

import asyncio
import random
from datetime import datetime

class RequestThrottler:
    """Giới hạn tần suất request với jitter ngẫu nhiên."""

    def __init__(self, min_delay: float = 2.0, max_delay: float = 8.0):
        self.min_delay = min_delay
        self.max_delay = max_delay
        self.last_request: dict[str, datetime] = {}

    async def wait_if_needed(self, source: str):
        now = datetime.utcnow()
        if source in self.last_request:
            elapsed = (now - self.last_request[source]).total_seconds()
            min_wait = self.min_delay * (1.0 + random.random())
            if elapsed < min_wait:
                await asyncio.sleep(min_wait - elapsed)
        self.last_request[source] = datetime.utcnow()
```

### 5.3 Khi chuyển sang tự code (Giai đoạn 2)

Khi scale và cần tự code crawler, áp dụng các biện pháp từ thiết kế cũ:
- Residential proxy rotation (Bright Data / Webshare)
- Random User-Agent pool (mobile + desktop VN)
- Header spoofing (Accept-Language, Referer, DNT)
- Regional consistency (IP, timezone, locale, UA khớp VN)
- Exponential backoff khi 429/503
- Không retry khi 403 (block)

---

## 6. APScheduler — Cơ chế Lập lịch

### 6.1 Kiến trúc tích hợp

```
FastAPI app (main.py)
    │
    └── lifespan()
          ├── start: BackgroundScheduler.start()
          │     ├── Job 1: crawl_google_trends    (cron: 0 */6 * * *)
          │     ├── Job 2: crawl_tiktok_trending   (cron: 15 */6 * * *)
          │     ├── Job 3: crawl_tiktok_kol_feed   (cron: 20 */6 * * *)
          │     ├── Job 4: crawl_facebook_groups   (cron: 30 */6 * * *)
          │     └── Job 5: update_seed_list        (cron: 0 3 * * SUN)  ← weekly
          │
          └── shutdown: scheduler.shutdown(wait=False)
```

**Offset 15 phút giữa các job:** Tránh spike tài nguyên, giảm khả năng bị rate limit đồng thời từ nhiều nguồn.

### 6.2 Triển khai

```python
# brandhub-ai-service/app/main.py

from contextlib import asynccontextmanager
from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.triggers.cron import CronTrigger
import logging

logger = logging.getLogger(__name__)

@asynccontextmanager
async def lifespan(app: FastAPI):
    # === Startup ===
    scheduler = BackgroundScheduler(timezone="Asia/Ho_Chi_Minh")

    # Job 1: Google Trends — mỗi 6 giờ, vào phút 0
    scheduler.add_job(
        crawl_google_trends_job,
        trigger=CronTrigger(hour="*/6", minute="0"),
        id="crawl_google_trends",
        name="Google Trends crawler",
        replace_existing=True,
        kwargs={"geo": "VN"},
    )

    # Job 2: TikTok trending — mỗi 6 giờ, vào phút 15
    scheduler.add_job(
        crawl_tiktok_trending_job,
        trigger=CronTrigger(hour="*/6", minute="15"),
        id="crawl_tiktok_trending",
        name="TikTok trending crawler",
        replace_existing=True,
    )

    # Job 3: TikTok KOL feed — mỗi 6 giờ, vào phút 20
    scheduler.add_job(
        crawl_tiktok_kol_feed_job,
        trigger=CronTrigger(hour="*/6", minute="20"),
        id="crawl_tiktok_kol_feed",
        name="TikTok KOL feed crawler",
        replace_existing=True,
    )

    # Job 4: Facebook search — mỗi 6 giờ, vào phút 30
    scheduler.add_job(
        crawl_facebook_groups_job,
        trigger=CronTrigger(hour="*/6", minute="30"),
        id="crawl_facebook_groups",
        name="Facebook search crawler",
        replace_existing=True,
    )

    # Job 5: Update KOL seed list — mỗi tuần, Chủ Nhật 03:00
    scheduler.add_job(
        update_seed_list_job,
        trigger=CronTrigger(day_of_week="sun", hour="3", minute="0"),
        id="update_kol_seed_list",
        name="Weekly KOL seed list update",
        replace_existing=True,
    )

    scheduler.start()
    logger.info("APScheduler started — 5 crawl jobs scheduled")

    yield  # === Runtime ===

    # === Shutdown ===
    scheduler.shutdown(wait=False)
    logger.info("APScheduler shut down")


app = FastAPI(lifespan=lifespan, ...)
```

### 6.3 Job Functions (MVP — API-based)

```python
# brandhub-ai-service/app/services/crawlers/scheduled_jobs.py

import logging
import json
from datetime import datetime
from pathlib import Path

# Google Trends (SerpApi — không có trên Apify/ScrapeCreators)
from app.services.crawlers.google_trends import fetch_trending_searches

# TikTok: dual source
from app.services.crawlers.tiktok_scrapecreators import (
    fetch_trending_feed,
    fetch_top_searches,
    fetch_popular_creators,
)
from app.services.crawlers.tiktok_apify import fetch_kol_feed_apify

# Facebook: Apify primary
from app.services.crawlers.facebook_apify import search_facebook_groups

from app.core.config import settings

logger = logging.getLogger(__name__)

TARGETED_KOLS = [...]          # Nạp từ file config
FB_SEARCH_TERMS = [...]        # Keywords tìm kiếm Facebook


async def crawl_google_trends_job(geo: str = "VN"):
    """Job 1: Google Trends trending searches (SerpApi)."""
    logger.info("[Crawl Job] Google Trends — starting...")
    try:
        trends = await fetch_trending_searches(geo=geo)
        _save_raw_output("google_trends", trends)
        logger.info(f"[Crawl Job] Google Trends — {len(trends)} trends fetched")
    except Exception as e:
        logger.error(f"[Crawl Job] Google Trends — FAILED: {e}")


async def crawl_tiktok_trending_job():
    """Job 2: TikTok trending feed + top searches (ScrapeCreators)."""
    logger.info("[Crawl Job] TikTok trending — starting...")
    try:
        # Lấy trending feed
        trending = await fetch_trending_feed(region="VN", count=30)
        _save_raw_output("tiktok_trending", trending)

        # Lấy top search queries (≈ trending topics)
        top_searches = await fetch_top_searches(region="VN")
        _save_raw_output("tiktok_top_searches", top_searches)

        logger.info(
            f"[Crawl Job] TikTok trending — {len(trending)} posts, "
            f"{len(top_searches)} top searches"
        )
    except Exception as e:
        logger.error(f"[Crawl Job] TikTok trending — FAILED: {e}")


async def crawl_tiktok_kol_feed_job():
    """Job 3: TikTok KOL feed (Apify TikTok Scraper)."""
    logger.info(f"[Crawl Job] TikTok KOL feed — {len(TARGETED_KOLS)} KOLs...")
    try:
        usernames = [k["username"] for k in TARGETED_KOLS[:20]]
        posts = await fetch_kol_feed_apify(usernames)
        _save_raw_output("tiktok_kol_feed", posts)
        logger.info(f"[Crawl Job] TikTok KOL feed — {len(posts)} posts fetched")
    except Exception as e:
        logger.error(f"[Crawl Job] TikTok KOL feed — FAILED: {e}")


async def crawl_facebook_groups_job():
    """Job 4: Facebook search (Apify Facebook Search Scraper)."""
    logger.info(f"[Crawl Job] Facebook search — {len(FB_SEARCH_TERMS)} terms...")
    try:
        posts = await search_facebook_groups(
            search_terms=FB_SEARCH_TERMS[:10],
            max_results=100,
        )
        _save_raw_output("facebook_groups", posts)
        logger.info(f"[Crawl Job] Facebook search — {len(posts)} posts fetched")
    except Exception as e:
        logger.error(f"[Crawl Job] Facebook search — FAILED: {e}")


async def update_seed_list_job():
    """Job 5 (hàng tuần): Cập nhật KOL list từ ScrapeCreators popular creators."""
    logger.info("[Crawl Job] Updating KOL seed list...")
    try:
        creators = await fetch_popular_creators(region="VN", count=50)
        _save_raw_output("kol_seed_update", creators)
        logger.info(f"[Crawl Job] Seed list — {len(creators)} creators fetched")
    except Exception as e:
        logger.error(f"[Crawl Job] Seed list update — FAILED: {e}")


# === Storage ===

def _save_raw_output(source: str, data: list[dict]):
    """Ghi dữ liệu thô vào Redis queue + file JSON backup."""
    timestamp = datetime.utcnow().strftime("%Y%m%d_%H%M%S")

    # 1. File JSON backup
    raw_dir = Path(settings.raw_data_dir) / source
    raw_dir.mkdir(parents=True, exist_ok=True)
    output_file = raw_dir / f"{timestamp}.json"
    output_file.write_text(
        json.dumps({"source": source, "crawl_time": datetime.utcnow().isoformat(), "posts": data}, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    logger.debug(f"Raw data saved: {output_file} ({len(data)} items)")

    # 2. Redis queue — push từng post vào list để pipeline sau consume
    # (triển khai sau khi Redis client được cấu hình trong ai-service)
    # await redis_client.lpush(f"raw:crawl:{source}", *[json.dumps(p) for p in data])
```

### 6.4 Multi-Worker Safety

Khi deploy với `uvicorn --workers 4`, mỗi worker chạy scheduler riêng → job chạy 4 lần.

**Giải pháp: File lock leader election (Windows-compatible)**

```python
# brandhub-ai-service/app/services/crawlers/scheduler_lock.py

import os
import sys
import msvcrt  # Windows-only

class SchedulerLock:
    """File lock để đảm bảo chỉ 1 worker chạy scheduler."""

    def __init__(self, lock_file: str = "/tmp/brandhub_scheduler.lock"):
        self.lock_file = lock_file
        self.locked = False

    def acquire(self) -> bool:
        """Thử acquire lock. Return True nếu là leader."""
        try:
            self.fd = os.open(self.lock_file, os.O_CREAT | os.O_RDWR)
            msvcrt.locking(self.fd, msvcrt.LK_NBLCK, 1)
            self.locked = True
            return True
        except (IOError, OSError):
            os.close(self.fd)
            return False

    def release(self):
        if self.locked:
            try:
                msvcrt.locking(self.fd, msvcrt.LK_UNLCK, 1)
            finally:
                os.close(self.fd)

# Trong lifespan():
lock = SchedulerLock()
if lock.acquire():
    scheduler.start()
    yield
    scheduler.shutdown()
    lock.release()
else:
    logger.info("Not scheduler leader — skipping APScheduler init")
    yield
```

### 6.5 Config cần thêm vào `app/core/config.py`

```python
# === Crawler API Keys (MVP) ===
# Google Trends
serpapi_api_key: str = ""                   # SerpApi — Google Trends (không có trên Apify/ScrapeCreators)

# Apify (TikTok KOL feed + Facebook search)
apify_api_token: str = ""                   # Apify API token — https://console.apify.com/settings/integrations

# ScrapeCreators (TikTok trending + hashtag)
scrapecreators_api_key: str = ""            # ScrapeCreators API key — https://scrapecreators.com/

# === APScheduler & Storage ===
raw_data_dir: str = "./data/raw"            # Thư mục lưu dữ liệu thô tạm
redis_password: str = ""                    # Redis password (để push queue)

# === Giai đoạn 2 (sau này) ===
# brightdata_customer_id: str = ""          # Bright Data proxy — chỉ cần khi tự code crawler
# brightdata_password: str = ""
```

---

## 7. Tầng Lưu trữ Đệm Thô (Raw Storage Buffer)

### 7.1 Thiết kế

Dữ liệu thô trước khi qua pipeline BM25 cần được lưu đệm ở 2 nơi:

```
Raw Crawl Output
      │
      ├── Redis Queue (primary)    ← key: raw:crawl:{source}
      │     Dạng: List (LPUSH/RPOP)
      │     TTL: 24h (đủ cho pipeline xử lý)
      │
      └── File JSON (backup)       ← path: data/raw/{source}/{timestamp}.json
            Dùng khi Redis down hoặc để audit/replay
            Cleanup: cron job xóa file > 7 ngày
```

### 7.2 Redis Queue Schema

```
Key:              raw:crawl:{source}
Type:             List
Push:             LPUSH (newest first)
Pop (consumer):   BRPOP (blocking read by BM25 pipeline)
TTL:              86400 (24 giờ)
Max length:       ~1000 entries (dùng LTRIM sau mỗi LPUSH)

Ví dụ:
  raw:crawl:google_trends   →  list các JSON object
  raw:crawl:tiktok_kol_feed →  list các JSON object
  raw:crawl:facebook_groups →  list các JSON object
```

### 7.3 File Backup Schema

```
data/raw/
├── google_trends/
│   ├── 20260803_000000.json
│   └── 20260803_060000.json
├── tiktok_trending/
│   └── 20260803_001500.json
├── tiktok_kol_feed/
│   └── 20260803_002000.json
└── facebook_groups/
    └── 20260803_003000.json
```

Cleanup cron (trong APScheduler):

```python
async def cleanup_old_raw_files(retention_days: int = 7):
    """Xóa file raw data cũ hơn retention_days."""
    cutoff = datetime.utcnow().timestamp() - (retention_days * 86400)
    raw_dir = Path(settings.raw_data_dir)
    for f in raw_dir.rglob("*.json"):
        if f.stat().st_mtime < cutoff:
            f.unlink()
            logger.debug(f"Cleaned old raw file: {f}")
```

---

## 8. Kiến trúc Tổng thể & Luồng Dữ liệu

```
┌─────────────────────────────────────────────────────────────────┐
│                    DATA COLLECTION LAYER (MVP)                    │
│                                                                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐   │
│  │ Google Trends │  │   TikTok     │  │  Facebook            │   │
│  │  (SerpApi)    │  │ (ScrapeCreat-│  │  (Apify Search)      │   │
│  │               │  │  ors + Apify)│  │                      │   │
│  └──────┬───────┘  └──────┬───────┘  └──────────┬───────────┘   │
│         │                 │                      │               │
│         │    Third-party APIs handle:            │               │
│         │    • Proxy rotation                    │               │
│         │    • Anti-bot / session                │               │
│         │    • Rate limiting                     │               │
│         │                 │                      │               │
│         └─────────────────┼──────────────────────┘               │
│                           │                                      │
│                    ┌──────▼───────┐                              │
│                    │   Throttler   │  ← Client-side rate limit   │
│                    └──────┬───────┘                              │
│                           │                                      │
│              ┌────────────┼────────────┐                        │
│              │            │            │                         │
│     ┌────────▼───┐  ┌─────▼────┐  ┌───▼──────────┐             │
│     │  Normalizer │  │  Duplicate│  │  Anti-Spam   │             │
│     │  (API→common│  │  Filter   │  │  Filter      │             │
│     │   schema)   │  │  (Redis)  │  │  (rules)     │             │
│     └────────┬───┘  └─────┬────┘  └───┬──────────┘             │
│              │            │            │                         │
│              └────────────┼────────────┘                        │
│                           │                                      │
│                    ┌──────▼───────┐                              │
│                    │  Raw Storage  │                              │
│                    │  Redis Queue  │  ← primary buffer           │
│                    │  + JSON File  │  ← backup                   │
│                    └──────┬───────┘                              │
└───────────────────────────┼─────────────────────────────────────┘
                            │
                            ▼
              ┌─────────────────────────┐
              │   DA-AI04-99-02         │
              │   BM25 Anomaly Engine   │
              │   (Consumer: BRPOP)     │
              └─────────────────────────┘
```

**Khác biệt chính với thiết kế cũ:**
- Không có Scrapy subprocess, không có Playwright browser, không có proxy manager
- Thay vào đó: 3 HTTP API calls → normalize → queue
- Anti-bot, proxy, retry đều do Apify/ScrapeCreators/SerpApi xử lý

**Luồng dữ liệu chi tiết (mỗi 6h):**

1. `00:00` — APScheduler trigger Google Trends job → SerpApi → normalize → push Redis `raw:crawl:google_trends`
2. `00:15` — APScheduler trigger TikTok trending job → ScrapeCreators API → normalize → push Redis `raw:crawl:tiktok_trending` + `raw:crawl:tiktok_top_searches`
3. `00:20` — APScheduler trigger TikTok KOL feed job → Apify Actor → poll → normalize → push Redis `raw:crawl:tiktok_kol_feed`
4. `00:30` — APScheduler trigger Facebook search job → Apify Actor → poll → normalize → push Redis `raw:crawl:facebook_groups`
5. `00:35` — BM25 pipeline (DA-AI04-99-02) bắt đầu consume từ các Redis queues
6. `~00:40` — Cleanup: xóa raw files > 7 ngày

---

## 9. Acceptance Criteria Checklist

- [x] **AC-1:** Tài liệu hóa cách cấu hình và giới hạn tần suất (rate limits) của Google Trends. `pytrends` đã archived — không có actor trên Apify/ScrapeCreators cho Google Trends. Giải pháp: **SerpApi Google Trends API** (primary) + DataForSEO (backup). Rate limit: 100 searches/tháng (free), 1,000+/tháng (paid $50). Chi tiết Section 2.

- [x] **AC-2:** Nghiên cứu và tài liệu hóa cơ chế cào dữ liệu từ TikTok Creative Center và API lấy bài đăng KOLs. Giải pháp MVP: **ScrapeCreators TikTok API** (trending feed + top search + hashtag, 22 endpoints, từ free đến $47/tháng) + **Apify TikTok Scraper** (KOL feed, 228K users, 4.8★, $1.70/1K results). Fallback: Playwright+stealth (không build trong MVP). Seed list tĩnh always-on. Chi tiết Section 3.

- [x] **AC-3:** Thiết kế luồng cào các Group Facebook công khai kết hợp dịch vụ proxy xoay vòng. Giải pháp MVP: **Apify Facebook Search Scraper** (`danek/facebook-search-ppr`, 5.8K users, 4.6★) — tự quản lý proxy. Fallback: ScrapeCreators Facebook API → Scrapy spider (không build trong MVP). Chi tiết Section 4.

- [x] **AC-4:** Cấu hình scheduler chạy ngầm thông qua thư viện `APScheduler` chạy định kỳ mỗi 6 giờ. `BackgroundScheduler` tích hợp trong FastAPI `lifespan`, 4 job offset 15 phút, file-lock leader election cho multi-worker safety. Chi tiết Section 6.

- [x] **AC-5 (bổ sung):** Chiến lược MVP API-first: dùng third-party API (Apify, ScrapeCreators, SerpApi) cho toàn bộ data collection. Tự code crawler dời sang Giai đoạn 2 (sau MVP). Tổng chi phí MVP: $0-$55/tháng. Time to market: 1-2 tuần thay vì 4-6 tuần. Chi tiết Section 1.

---

## 10. Dependencies & Next Steps

### 10.1 Blocked by

_(Không — đây là task đầu tiên trong Epic)_

### 10.2 Blocks

- **DA-AI04-99-02** — Nghiên cứu thuật toán Động cơ dự đoán xu hướng (Tách từ & BM25 Anomaly Detection)

### 10.3 Action Items cho giai đoạn MVP

| # | Action | Priority | Người |
|---|---|---|---|
| 1 | Đăng ký SerpApi account, lấy API key, test `google_trends_trending_now` endpoint | 🔴 P0 | Tuấn |
| 2 | Đăng ký Apify account, tạo API token, test `clockworks/tiktok-scraper` actor (gọi qua API) | 🔴 P0 | Tuấn |
| 3 | Đăng ký ScrapeCreators account (Free tier), test `/v1/tiktok/get-trending-feed` | 🔴 P0 | Tuấn |
| 4 | Đăng ký Apify `danek/facebook-search-ppr` actor, test search bằng keyword tiếng Việt | 🔴 P0 | Tuấn |
| 5 | Implement `tiktok_scrapecreators.py` + `tiktok_apify.py` + `facebook_apify.py` + `google_trends.py` | 🔴 P0 | Tuấn |
| 6 | Implement normalizer: Apify/ScrapeCreators/SerpApi output → schema chung | 🔴 P0 | Tuấn |
| 7 | Thêm config fields vào `app/core/config.py` và `.env.example` | 🔴 P0 | Tuấn |
| 8 | Implement scheduled jobs + APScheduler trong `app/main.py` lifespan | 🔴 P0 | Tuấn |
| 9 | Build targeted KOL list (50-100 TikTok usernames) + Facebook search terms | 🟡 P1 | Tuấn + Team |
| 10 | Test end-to-end: scheduler trigger → API calls → normalize → Redis queue → verify data | 🔴 P0 | Tuấn |

### 10.4 Action Items cho Giai đoạn 2 (Scale — sau MVP)

| # | Action | Priority | Trigger |
|---|---|---|---|
| G2-1 | Đánh giá chi phí API sau 1 tháng. Nếu >$100/tháng → build crawler riêng cho source đắt nhất | 🟡 P1 | Cost review |
| G2-2 | Build Playwright+stealth fallback cho TikTok nếu Apify/ScrapeCreators cùng down | 🟢 P2 | Incident |
| G2-3 | Build Scrapy spider cho Facebook nếu Apify Search không cover group đủ | 🟢 P2 | Data gap |
| G2-4 | Đăng ký Bright Data/Webshare proxy nếu cần tự code crawler | 🟢 P2 | G2-2 or G2-3 |

### 10.5 Risk Register

| Risk | Impact | Mitigation |
|---|---|---|
| Apify TikTok Scraper actor bị gỡ khỏi store | HIGH | ScrapeCreators TikTok API là fallback trực tiếp (22 endpoints) |
| ScrapeCreators tăng giá / đổi pricing model | MEDIUM | Free tier đủ cho test; Freelance $47/tháng vẫn rẻ hơn tự code |
| Apify Facebook Search không cover group posts | MEDIUM | Test sớm (Action #4). Nếu fail → ScrapeCreators Facebook API → Scrapy |
| API key bị leak → bị abuse → hết quota | HIGH | Dùng `.env`, không commit key. Đặt usage alert trên Apify/ScrapeCreators dashboard |
| SerpApi hết quota giữa tháng (free tier) | LOW | Nâng lên Starter $50/tháng hoặc dùng DataForSEO fallback |
| Chi phí API vượt ngân sách khi scale | LOW | Theo dõi monthly. Giai đoạn 2 tự code những source đắt nhất |

---

## References

**Third-party API Platforms (MVP):**
- [Apify Store](https://apify.com/store) — TikTok Scraper, Facebook Search Scraper
- [ScrapeCreators](https://scrapecreators.com/) — TikTok API (22 endpoints), Facebook API (11 endpoints)
- [Apify TikTok Scraper](https://apify.com/clockworks/tiktok-scraper) — 228K users, 4.8★, $1.70/1K results
- [Apify Facebook Search Scraper](https://apify.com/danek/facebook-search-ppr) — 5.8K users, 4.6★
- [ScrapeCreators TikTok API Docs](https://docs.scrapecreators.com/) — Endpoint reference
- [ScrapeCreators Pricing](https://scrapecreators.com/) — Free (100 credits), Freelance $47/mo, Business $497/mo

**Google Trends (API chuyên biệt):**
- [SerpApi Google Trends API](https://serpapi.com/google-trends-api)
- [DataForSEO Google Trends API](https://dataforseo.com/apis/google-trends-api)
- [pytrends GitHub (archived)](https://github.com/GeneralMills/pytrends) — Archived April 2025

**Custom Crawler (Giai đoạn 2 — tham khảo):**
- [Playwright Stealth — ZenRows Guide](https://www.zenrows.com/blog/playwright-stealth)
- [pw-stealth-enhanced (PyPI)](https://pypi.org/project/pw-stealth-enhanced/)
- [Bright Data Residential Proxies](https://brightdata.com/proxy-types/residential-proxies)
- [Webshare Proxy](https://www.webshare.io/)

**Infrastructure:**
- [APScheduler Documentation](https://apscheduler.readthedocs.io/)
- [FastAPI Lifespan (official)](https://fastapi.tiangolo.com/advanced/events/)
- [TikTok Algorithm 2026 — Darkroom Agency](https://www.darkroomagency.com/observatory/how-tiktok%E2%80%99s-algorithm-works-in-2026-and-15-tactics-to-go-viral)

**Internal:**
- [BrandHub Market Comparison](../idea/idea_crawData_algorithm/market_comparison.md)
- [BrandHub Architecture](../idea/idea_crawData_algorithm/ARCHITECTURE.md)
