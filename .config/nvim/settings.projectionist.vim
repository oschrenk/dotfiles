" ---------------------------
" vim-projectionist
" ---------------------------

if !exists('g:projectionist_heuristics')
  let g:projectionist_heuristics = {}
endif
if !has_key(g:projectionist_heuristics, "build.sbt")
  let g:projectionist_heuristics["build.sbt"] = {
      \  "src/main/scala/*.scala": {
      \    "alternate": "src/test/scala/{}Spec.scala",
      \    "type": "source"
      \  },
      \  "src/test/scala/*Spec.scala": {
      \    "alternate": "src/main/scala/{}.scala",
      \    "type": "test"
      \  }
      \}
endif

