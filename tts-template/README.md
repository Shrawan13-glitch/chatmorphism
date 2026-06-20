# ShryneTTS Generator

Your personal TTS generator, powered by [ShryneTTS](https://github.com/marketplace/actions/shrynetts) (Kokoro).

Triggered via the Kino app or `gh` CLI:

```bash
gh workflow run generate.yml -f items='[{"text":"Hello world","voice":"af_sky"}]'
gh run download $(gh run list --json databaseId -q '.[0].databaseId') --name tts-output
```
