# MP4 upload detection
Accept valid ISO MP4 files when Tika identifies their container as video/quicktime. Preserve structural moov/trak/mdat validation, file size limits and pre-S3 encryption. Do not accept arbitrary QuickTime or disguised files as MP4. Return a specific localized format error instead of a generic retry instruction.
VI/EN: repositoryUpload.invalidContent. Existing semantic error styling supports both themes; no layout change.
