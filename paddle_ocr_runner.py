#!/usr/bin/env python3
"""Lightweight PaddleOCR runner for MTG card title extraction.

Outputs JSON with two keys:
- best_text: best candidate line
- lines: list of {text, score, box}

Requires: pip install paddleocr
"""
import argparse
import json
import sys
from typing import List, Dict, Any

try:
    from paddleocr import PaddleOCR  # type: ignore
except ImportError:
    sys.stderr.write("PaddleOCR not installed. Run: pip install paddleocr\n")
    sys.exit(1)


def run_ocr(image_path: str, lang: str) -> List[Dict[str, Any]]:
    # show_log is unsupported on this PaddleOCR version; omit it
    ocr = PaddleOCR(use_textline_orientation=True, lang=lang)
    result = ocr.ocr(image_path, cls=True)
    lines: List[Dict[str, Any]] = []

    for page in result:
        for line in page:
            text = line[1][0]
            score = float(line[1][1])
            box = line[0]
            lines.append({"text": text, "score": score, "box": box})

    # Sort by confidence, high to low
    lines.sort(key=lambda item: item["score"], reverse=True)
    return lines


def pick_best_text(lines: List[Dict[str, Any]]) -> Dict[str, Any]:
    best = next((l for l in lines if len(l.get("text", "")) > 2), None)
    if not best:
        return {"best_text": None, "best_score": None}
    return {"best_text": best["text"], "best_score": best["score"]}


def main() -> None:
    parser = argparse.ArgumentParser(description="Run PaddleOCR and emit JSON")
    parser.add_argument("--image", required=True, help="Path to image")
    parser.add_argument("--lang", default="en", help="Language code (default: en)")
    parser.add_argument("--mode", choices=["name", "full"], default="name", help="Extraction mode")
    args = parser.parse_args()

    lines = run_ocr(args.image, args.lang)
    best = pick_best_text(lines)

    payload = {
        "lines": lines if args.mode == "full" else lines[:10],
        "best_text": best["best_text"],
        "best_score": best["best_score"],
    }

    print(json.dumps(payload, ensure_ascii=True))


if __name__ == "__main__":
    main()
