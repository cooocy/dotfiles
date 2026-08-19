" jsonc 自带语法里有几个跨行正则（jsonStringMatch / jsonTrailingCommaError）
" 使用 \_s* 配合 * 重复，会触发灾难性回溯，导致打开文件卡 2 秒。
" 但不能直接 syn clear jsonStringMatch，否则连 json.vim 原版也被清掉，
" 字符串值不再被识别，里面的单词会被 jsonNoQuotesError 当错误高亮。
" 做法：清除后只加回 json.vim 的单行版本（快且够用）。

syn clear jsonStringMatch
syn match jsonStringMatch /"\([^"]\|\\\"\)\+"\ze[[:blank:]\r\n]*[,}\]]/ contains=jsonString

" 尾逗号错误同理，清掉跨行版，加回 json.vim 的单行版
syn clear jsonTrailingCommaError
syn match jsonTrailingCommaError ",\_s*[}\]]"
