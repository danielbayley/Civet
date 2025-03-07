<script lang="ts" setup>
import { onMounted, ref, watch, nextTick, computed } from 'vue';
import { compileCivetToHtml } from '../utils/compileCivetToHtml';
import { b64 } from '../utils/b64';
import { ligatures } from '../store/ligatures.store';

const emit = defineEmits(['input']);
const props = defineProps<{
  b64Code: string;
  compileAtStart?: boolean;
  emitJsOutput?: boolean;
  clearTrigger?: boolean;
  hideLink?: boolean;
}>();

const userCode = ref(b64.decode(props.b64Code));
const compileError = ref<string | undefined>('');
const inputHtml = ref('');
const outputHtml = ref('');
const inputHtmlEl = ref<HTMLDivElement>();
const textareaEl = ref<HTMLTextAreaElement>();

// Compile on input
onMounted(fixTextareaSize);
watch(userCode, compile);

// Clear
watch(
  () => props.clearTrigger,
  () => (userCode.value = '')
);

// Compile client side
const loading = ref(true);
onMounted(async () => {
  if (props.compileAtStart) {
    await compile();
    loading.value = false;
    await nextTick();
    fixTextareaSize();
  }
});

async function compile() {
  const snippet = await compileCivetToHtml({
    code: userCode.value + '\n',
    jsOutput: props.emitJsOutput,
  });

  emit('input', userCode.value, snippet.jsCode);

  compileError.value = snippet.error;
  inputHtml.value = snippet.inputHtml;

  if (snippet.outputHtml) {
    outputHtml.value = snippet.outputHtml;
  }

  await nextTick();
  fixTextareaSize();
}

function fixTextareaSize() {
  if (textareaEl.value && inputHtmlEl.value) {
    textareaEl.value.style.height = `${inputHtmlEl.value.clientHeight}px`;
    textareaEl.value.style.width = `${
      inputHtmlEl.value.querySelector('code')!.scrollWidth + 20
    }px`;
  }
}

const playgroundUrl = computed(() => {
  return `/playground?code=${b64.encode(userCode.value)}`;
});
</script>

<template>
  <div v-if="props.compileAtStart && loading">Loading playground...</div>
  <div v-else :class="{ wrapper: true,  ligatures: ligatures}">
    <div class="col scroll" @click="textareaEl?.focus()">
      <div class="code code--user">
        <textarea
          :value="userCode"
          :onInput="(e: any) => (userCode = e.target.value)"
          ref="textareaEl"
          resize="false"
          spellcheck="false"
          class="textarea shiki one-dark-pro"
        />
      </div>

      <div class="code code--input" ref="inputHtmlEl">
        <div v-if="inputHtml" v-html="inputHtml" />
        <slot v-else name="input" />
      </div>

      <div class="compilation-info" v-if="!hideLink">
        <span>
          Edit inline or
          <a
            :href="playgroundUrl"
            @click.prevent
            class="edit-in-the-background"
          >
            edit in the Playground!
          </a>
        </span>
        <span v-if="inputHtml && compileError"> ❌ Compile error ❌</span>
      </div>
    </div>

    <div class="col" :class="{ 'col--error': compileError }">
      <div class="code code--output">
        <div v-if="outputHtml" v-html="outputHtml" />
        <slot v-else name="output" />
      </div>
      <label class="compilation-info">
        <input type="checkbox" v-model="ligatures"/>
        Ligatures
      </label>
    </div>
  </div>
</template>

<style scoped>
.wrapper {
  display: flex;
  flex-wrap: wrap;
  justify-content: space-between;
  align-items: stretch;
}

.col {
  margin: 8px 0;
  position: relative;
  background: var(--vp-code-block-bg);
  border-radius: 5px;
  border: 1px solid transparent;
  transition: border-color 0.15s;
  width: calc(50% - 10px);
}

.col--error {
  border: 1px solid var(--vp-c-red-dimm-1);
}

.scroll {
  overflow-x: auto;
  overflow-y: hidden;
}

@media (max-width: 767px) {
  .col {
    width: 100%;
  }
}

.code {
  width: 100%;
  cursor: text;
  margin-bottom: 20px;
}

.code--user {
  position: absolute;
  left: 0;
  top: 0;
  z-index: 3;
  min-height: 100%;
  background: transparent;
}

.code--input {
  z-index: 2;
}

.textarea {
  min-width: 100%;
  height: 100%;
  padding: 16px 18px;
  caret-color: var(--vp-c-text-1);
  line-height: var(--vp-code-line-height);
  font-size: var(--vp-code-font-size);
  background: transparent;
  resize: none;
  color: transparent;
  overflow-x: visible;
  overflow-y: hidden;
}

.compilation-info {
  position: absolute;
  right: 8px;
  bottom: 3px;
  font-size: 12px;
  color: var(--vp-c-text-dark-1);
  opacity: 0.5;
  z-index: 4;
}

.edit-in-the-background {
  cursor: pointer;
  color: var(--vp-c-green-light);
  padding: 10px 0;
}

.code:deep(code) {
  display: block;
  padding: 0 18px;
  width: fit-content;
  line-height: var(--vp-code-line-height);
  font-size: var(--vp-code-font-size);
  color: var(--vp-code-block-color);
  transition: color 0.5s;
}

.code:deep(pre) {
  height: 100%;
  position: relative;
  z-index: 1;
  margin: 0;
  padding: 16px 0;
  background: transparent;
  overflow-x: auto;
  background-color: transparent !important;
  border-radius: 5px;

  position: relative;
  z-index: 1;
}

.code--input:deep(pre) {
  overflow: visible;
}

input { vertical-align: middle; }
</style>
