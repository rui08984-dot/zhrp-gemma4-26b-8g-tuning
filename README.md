# 中文标定 Gemma-4-26B RP 档 · 8GB 笔记本实测（三档 ub 配方）

> EN: Chinese-calibrated Gemma-4-26B roleplay tuning on 8GB laptop: three-tier ubatch recipe (64K/118K/128K), NO_PINNED on 32GB, measured PP/TG.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

**硬件**：RTX 4060 Laptop 8GB · 32GB DDR5 双通道 · Windows 11 · llama.cpp 系 fork

**量化**：Q5_K_M（17.8 GB, 作者中文 imatrix 标定）

**引擎**：**AtomicBot b10269-1.6.0** + `GGML_CUDA_NO_PINNED=1`（32G 机器实测）

## 生产配置（start.bat 即仓库内同名文件，零漂移）

```bat
-ctk q8_0 -ctv q4_0 -b 2816 -ub 2816 --threads 6（主力档）
```

## 实测结果（服务端真实长提示口径）

| 深度 | PP (tok/s) | TG (tok/s) |
|---|---|---|
| 20K | 1084 | 25.2 |
| 40K | 1004 | — |
| 64K | 936 | 19.6 |
| 82-118K | — | 18.8（ub1024） |
| 128K | — | 15.6（ub512） |

## 关键发现

- **三档 ub 配方**：≤64K 用 ub2816；82-118K 切 ub1024；128K 切 ub512——按上下文深度切换微批大小。
- turbo4 KV × gemma4 = fit 卡死（fork 实测），老实用 q8_0/q4_0。
- 中文标定 > 量化档位：同基座 PPL 39.31（中文标定 IQ3_XXS）反超 48.69（APEX I-Quality）——中文场景标定数据比量化策略更值钱。
- RP 14 轮实战胜过同尺寸通用模型（有观点、有记忆点、无替用户做决定违规）。
- MTP 草稿判死：接受率 0.248→0.268 仍 -26%，改权重废 MTP 头。

## 复现

```bash
python tools/depth_probe_atomic.py <模型.gguf> <端口> <标签> --depths 0,32768,65536,98304,118784 -ctk turbo4 -ctv turbo4 -b 2816 -ub 2816 --threads 24
python tools/test_engines.py
```

## data/ 与 tools/

`data/` 是全部实测数据（summary_*.txt 为权威深度/预填/矩阵总表，每行带时间戳，可复现）。
`tools/` 是探针与判分脚本（服务端真实长提示口径；llama-bench pp512 在本机与真实负载差 2.8 倍，仅作参考）。

## 姊妹仓库（同机同方法论）

- [ornith-1.5-35b-8g-tuning](https://github.com/rui08984-dot/ornith-1.5-35b-8g-tuning)
- [kat-coder-35b-8g-tuning](https://github.com/rui08984-dot/kat-coder-35b-8g-tuning)
- [qwen3.6-35b-8g-tuning](https://github.com/rui08984-dot/qwen3.6-35b-8g-tuning)
- [bonsai2-27b-8g-tuning](https://github.com/rui08984-dot/bonsai2-27b-8g-tuning)
- [ornith-9b-kvmem-8g-tuning](https://github.com/rui08984-dot/ornith-9b-kvmem-8g-tuning)

## 致谢

- [ggml-org/llama.cpp](https://github.com/ggml-org/llama.cpp) — 本体
- [TheTom/llama-cpp-turboquant](https://github.com/TheTom/llama-cpp-turboquant) — turbo4 KV 原始 fork
- [AtomicBot-ai/atomic-llama-cpp-turboquant](https://github.com/AtomicBot-ai/atomic-llama-cpp-turboquant) — 现用构建
- [PrismML](https://huggingface.co/PrismML) — Bonsai 三值 QAT
- KVMem — KV-in-RAM 超长上下文引擎

## License

MIT。模型权重遵循各自发布页许可。
