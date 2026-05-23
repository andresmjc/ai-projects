# AI Projects Monorepo

This repository is structured to support development across multiple platforms and AI providers. You can develop web apps, APIs, mobile apps, games, and use models/services from Google AI Studio, OpenAI, Azure AI, HuggingFace, and more.

## Structure Overview

```
ai-projects/
├── README.md
├── .gitignore
├── docs/
├── shared/
│   ├── utils/
│   ├── configs/
│   └── ...
├── ai-services/
│   ├── google-ai-studio/
│   ├── openai/
│   ├── azure-ai/
│   ├── huggingface/
│   └── other/
├── apps/
├── apis/
├── mobile/
├── games/
└── scripts/
```

- Each subfolder contains independent projects and their own documentation (`README.md`).
- `ai-services/` is subdivided by AI provider.
- `shared/` holds utilities and shared code/configs.
- Add new providers/tools easily by adding new subfolders.

## Get Started
- See individual folders for `README.md` and setup instructions.
- Use the `docs/` folder for cross-project architecture or documentation.
