# DA-59 — AI Fashion Model Generation Platforms

## 1. Executive Summary

AI-generated fashion models are becoming a practical way to reduce visual production cost, shorten campaign asset creation time, and create more variations for ads, social posts, product showcases, and brand concept testing.

This report evaluates **exactly 3 AI model/workflow candidates** that were tested for fashion model generation:

1. **InstantID**
2. **InstantID + ControlNet**
3. **Z-Image**

Two additional tools were considered but not included in the final 3-model analysis:

| Tool | Reason excluded |
|---|---|
| ControlNet standalone | Không có demo để test, nên không có kết quả thực tế. |
| IP-Adapter | Không có demo để test, nên không có kết quả thực tế. |

> Note: Jira acceptance criteria mentions visual demo images, but this Markdown version intentionally does **not** include images because the current request explicitly says **không cần ảnh**.

---

## 2. Evaluation Context

### Goal

Research and compare AI models/platforms capable of generating high-quality AI fashion models for BrandHub marketing workflows.

### BrandHub Use Case

BrandHub needs AI fashion model generation for:

- Fast campaign visual prototyping.
- Social media ad concepts.
- Fashion model images with controllable outfit, pose, style, and background.
- Reducing dependency on manual photoshoots during early campaign ideation.

### Evaluation Criteria

| Criteria | What was checked |
|---|---|
| Prompt understanding | Whether the model follows clothing, style, pose, and scene instructions. |
| Face consistency | Whether the generated face remains stable and realistic. |
| Pose/body quality | Whether body shape, pose, hands, legs, and full-body framing look correct. |
| Fashion realism | Clothing fit, fabric folds, texture, lighting, and styling quality. |
| Background quality | Whether the generated background is coherent and usable for marketing. |
| Speed | Practical generation speed during testing. |
| Production fit | Whether the workflow can support BrandHub MVP or later production. |

---

## 3. Model Analysis

---

### 3.1 InstantID

#### Overview

InstantID is an identity-preserving image generation workflow that uses a reference face to guide the generated output. It is typically used with diffusion-based pipelines when the goal is to keep a specific identity or face style while still following a text prompt.

For BrandHub, InstantID is relevant because fashion campaigns may need consistent virtual model faces across multiple generated assets.

| Field | Assessment |
|---|---|
| Deployment type | Open-source / custom workflow |
| Technology direction | Diffusion workflow with identity conditioning |
| Main use case | Identity-conditioned fashion model generation |
| Best fit | Fast concept generation with a reference face |
| Tested result | Prompt understanding is good and generation speed is fast, but face drift is high |

#### Core Features

- Uses a reference identity to guide the generated face.
- Supports prompt-based control for outfit, scene, style, and model description.
- Can generate images quickly for concept exploration.
- Can be integrated into Stable Diffusion-style pipelines.
- May support further workflow extension depending on the chosen base model and UI/runtime.

#### Output Quality

| Aspect | Evaluation |
|---|---|
| Prompt understanding | Good. The model generally understands prompt intent well. |
| Face consistency | Weak. Face drift is significant across outputs. |
| Anatomical correctness | Acceptable for simple compositions, but not reliable enough for final campaign assets. |
| Fashion details | Usable for early concept output, but requires curation. |
| Lighting consistency | Moderate; acceptable in simple scenes. |
| Texture details | Medium; not the strongest candidate for garment realism. |
| Style control | Weak in testing because output was too biased toward anime/stylized looks. |
| Background generation | Usable for simple scenes, but not a key strength. |

#### Test Result Summary

**Điểm tốt:**

- Prompt được hiểu khá tốt.
- Tốc độ tạo nhanh.

**Điểm không tốt:**

- Drift mặt khá nhiều.
- Quá thiên về style anime.

#### Pricing & Licensing

InstantID is treated as an open-source/custom workflow option. The direct software cost can be low, but real production cost includes:

- GPU inference cost.
- Engineering setup and maintenance.
- Workflow hosting.
- Manual QA and output selection.

Commercial usage must be verified against the exact InstantID implementation, base diffusion model, checkpoints, LoRA/style models, and any third-party assets used in the final pipeline.

#### BrandHub Fit

InstantID is useful for fast internal experiments and identity-based concept generation. However, it is not recommended as the main production workflow because face drift and anime-style bias are too risky for BrandHub marketing visuals.

---

### 3.2 InstantID + ControlNet

#### Overview

InstantID + ControlNet combines identity conditioning with structural control. InstantID guides the face/identity, while ControlNet helps control pose, layout, edge map, depth, or other structural information.

For BrandHub, this workflow is attractive because fashion model images often require stable pose, controlled framing, and consistent composition.

| Field | Assessment |
|---|---|
| Deployment type | Open-source / custom workflow |
| Technology direction | Diffusion workflow with identity conditioning + pose/layout control |
| Main use case | Identity-conditioned generation with stronger pose control |
| Best fit | Fashion concepts where pose stability matters |
| Tested result | Prompt understanding and speed are good; pose is stable, but face drift and background issues remain |

#### Core Features

- Identity conditioning through InstantID.
- Pose or structure control through ControlNet.
- Better control over model pose than InstantID alone.
- Can support full-body or pose-specific fashion composition if the control input is good.
- More flexible than InstantID alone, but also more complex to tune.

#### Output Quality

| Aspect | Evaluation |
|---|---|
| Prompt understanding | Good. Prompt intent is generally followed. |
| Face consistency | Weak. Face drift remains a major issue. |
| Anatomical correctness | Better than InstantID alone because pose is controlled. |
| Pose/body quality | Good. Pose and body direction are more stable. |
| Fashion details | Medium. Better framing potential, but still needs manual selection. |
| Lighting consistency | Medium; can vary depending on background and control input. |
| Texture details | Medium; acceptable for concept output. |
| Background generation | Weak. Tested outputs showed broken/corrupted background. |
| Production quality | Better than InstantID alone for pose, but still not stable enough for fully automated final assets. |

#### Test Result Summary

**Điểm tốt:**

- Prompt được hiểu khá tốt.
- Tốc độ tạo nhanh.
- Pose dáng ổn.

**Điểm không tốt:**

- Drift mặt khá nhiều.
- Background bị hỏng.

#### Pricing & Licensing

This is also an open-source/custom workflow. If self-hosted, there is usually no SaaS subscription cost, but the team must account for:

- GPU runtime.
- Workflow setup and debugging.
- Model serving.
- Control image preprocessing.
- QA effort for failed backgrounds or identity drift.

Commercial usage depends on the selected base model, InstantID implementation, ControlNet model, checkpoints, LoRA/style models, and any other dependencies. License verification is required before production use.

#### BrandHub Fit

InstantID + ControlNet is better than InstantID alone when pose control is important. However, because background quality and face drift are still problematic, it should be treated as an R&D workflow or semi-manual creative workflow rather than the main automated image generation solution.

---

### 3.3 Z-Image

#### Overview

Z-Image is an open-source image generation model/workflow evaluated for high-quality fashion model generation. In testing, it produced the strongest visual result among the candidates.

For BrandHub, Z-Image is relevant because output quality is closer to marketing-ready visuals, especially for portrait, upper-body, or medium-shot fashion images.

| Field | Assessment |
|---|---|
| Deployment type | Open-source |
| Technology direction | Image generation model/workflow |
| Main use case | High-quality fashion model image generation |
| Best fit | Fashion visuals where overall image quality matters more than identity LoRA customization |
| Tested result | Very good image quality, but full-body generation can break face quality |

#### Core Features

- Generates high-quality fashion model images.
- Open-source direction makes it more flexible than closed SaaS products.
- Suitable for campaign concept creation and visual experimentation.
- Can be self-hosted depending on available model weights and infrastructure.
- Strong candidate for marketing visuals where the model does not need a fixed identity across many outputs.

#### Output Quality

| Aspect | Evaluation |
|---|---|
| Prompt understanding | Good enough for fashion visual generation. |
| Face consistency | Good in close/medium shots, weaker in full-body outputs. |
| Anatomical correctness | Stronger in portrait or half-body framing; full-body can reduce face quality. |
| Pose/body quality | Good for non-full-body compositions. |
| Fashion details | Strongest among tested candidates. |
| Lighting consistency | Good based on tested result. |
| Texture details | Good; more suitable for marketing visuals than the other tested options. |
| Background generation | Better than InstantID + ControlNet in tested result. |
| Production quality | Most promising option for BrandHub among the tested models. |

#### Test Result Summary

**Điểm tốt:**

- Tạo ảnh cực kì ổn.
- Open-source.

**Điểm không tốt:**

- Tạo full body sẽ bị lỗi mặt.
- Không LoRA được trong workflow đã test.

#### Pricing & Licensing

Z-Image is treated as an open-source/self-host option in this evaluation. Direct platform cost is lower than typical SaaS tools, but practical cost includes:

- GPU inference.
- Setup and model serving.
- Storage for generated outputs.
- Review and QA time.
- Possible engineering work to integrate into BrandHub AI service.

Commercial usage rights must be verified against the exact Z-Image repository/model license and dependencies before using generated assets in paid campaigns.

#### BrandHub Fit

Z-Image is the strongest candidate for BrandHub's current needs because it produced the best visual quality in testing and is open-source. It is most suitable for campaign visuals where the generated model does not need strict identity preservation or LoRA-based personalization.

The main limitation is full-body generation. For production, BrandHub should prefer portrait, half-body, or three-quarter compositions until full-body face quality is more stable.

---

## 4. Tools Not Included in Final 3-Model Analysis

| Tool | Test result | Decision |
|---|---|---|
| ControlNet standalone | Không có demo để test, nên không có kết quả. | Not included in final 3-model analysis. |
| IP-Adapter | Không có demo để test, nên không có kết quả. | Not included in final 3-model analysis. |

These tools may still be useful later as supporting components, especially for pose control or reference-image guidance. However, they should not be counted as one of the three evaluated models in this report because there are no test results.

---

## 5. Comparison Matrix

| Criteria | InstantID | InstantID + ControlNet | Z-Image |
|---|---|---|---|
| Deployment type | Open-source/custom workflow | Open-source/custom workflow | Open-source |
| Main strength | Fast identity-conditioned generation | Better pose control | Best image quality |
| Prompt understanding | Good | Good | Good |
| Face consistency | Weak; face drift is high | Weak; face drift remains | Good in close/medium shots, weak in full-body |
| Pose control | Medium | Good | Medium |
| Background quality | Medium | Weak; background can break | Good based on tested result |
| Fashion realism | Medium | Medium | High |
| Fabric/texture detail | Medium | Medium | High |
| Full-body reliability | Medium-low | Medium | Low for face quality |
| LoRA support | Possible depending on pipeline | Possible depending on pipeline | Not supported in tested workflow |
| Speed | Fast | Fast | Not explicitly measured; quality is strongest |
| Cost | GPU/self-host cost | GPU/self-host cost | GPU/self-host cost |
| Learning curve | Medium | High | Medium |
| Production readiness | Low-medium | Medium for controlled experiments | Highest among tested candidates |

---

## 6. Recommendation

### Recommended Option: Z-Image

Z-Image is the best fit for BrandHub's current project requirements because it produced the strongest visual quality in testing and is open-source. It is the most promising candidate for generating marketing-style AI fashion model images when the output does not require strict identity preservation or LoRA-based customization.

### Recommended Usage Strategy

Use Z-Image as the primary candidate for AI fashion model visual generation, with these constraints:

- Prefer portrait, half-body, or three-quarter fashion model shots.
- Avoid full-body generation when face detail is important.
- Use manual review/selection before using outputs in marketing assets.
- Keep InstantID + ControlNet as an R&D option when pose control is required.
- Do not select InstantID alone as the core workflow because face drift and anime-style bias are too risky for BrandHub's marketing use case.

### Final Ranking

| Rank | Model / Workflow | Decision |
|---|---|---|
| 1 | Z-Image | Best candidate for current project |
| 2 | InstantID + ControlNet | Useful for controlled pose experiments |
| 3 | InstantID | Useful for quick tests only, not recommended as core pipeline |

---

## 7. Acceptance Criteria Tracking

| Acceptance Criteria | Status | Note |
|---|---|---|
| Document link attached to Jira | Pending | Attach this Markdown document or published docs link to DA-59. |
| In-depth analysis of exactly 3 AI models | Done | InstantID, InstantID + ControlNet, Z-Image. |
| Visual demo images generated by each tool | Not included by request | Current request explicitly says no images. |
| Clear comparison matrix | Done | See Section 5. |
| Final recommendation | Done | Z-Image recommended. |
| Professional formatting and grammar | Done | Markdown report created for docs repo. |

---

## 8. Next Steps

1. Attach this document or docs portal link to Jira DA-59.
2. Add demo images later if PO/Manager requires strict Jira acceptance compliance.
3. Run an additional Z-Image benchmark focused on:
   - half-body fashion model image
   - full-body image
   - product-focused prompt
   - background-heavy campaign prompt
4. Verify Z-Image license and dependencies before commercial use.
5. Re-test ControlNet standalone and IP-Adapter when a usable demo/runtime is available.
