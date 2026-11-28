Video insertion with confirmed source audio creates synchronized video and audio elements. Disable embedded audio on the video to avoid doubling. Silent videos and images remain visual only. Existing projects are unchanged. Undo/redo handles the pair together. No new UI text or theme changes.
Follow-up: opening an existing scene also separates enabled video source audio when confirmed present; already separated clips remain unchanged. Conversion is a single undoable command batch.
Preview must release its rendering lock after a failed frame and retry without marking that frame complete.
