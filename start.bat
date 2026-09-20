@echo off
rem start-zhRP.bat - zh-RP gemma-4-26B Q5_K_M production launcher (0920 final)
rem Tuned config: main tier ub2816 for RP depth <=64K. Deeper tiers:
rem   82-118K: change -ub to 1024 ; 128K: change -ub to 512 (see tuning logs)
rem GGML_CUDA_NO_PINNED=1: community hygiene for 32GB RAM hosts (pinned ballooning)
set GGML_CUDA_NO_PINNED=1
rem NEVER enable --swa-full (full KV on gemma4 = OOM + slowdown).
cd /d D:\llm\bin\atomic-b10269\pkg\build\bin
llama-server.exe ^
  -m "D:\lmstudio-models\zhRP\gemma-4-26B-A4B-it-heretic-zh-RP-Q5_K_M.gguf" ^
  -c 73728 -np 1 -fa on ^
  -ctk q8_0 -ctv q4_0 ^
  -b 2816 -ub 2816 ^
  --threads 24 --threads-batch 12 ^
  --no-mmap --mlock --cache-ram 0 ^
  --spec-type none --reasoning off --jinja ^
  --cache-prompt --ctx-checkpoints 8 ^
  --host 127.0.0.1 --port 24561
pause
