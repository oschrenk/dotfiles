function llm
    set -x OPENAI_API_KEY (op read "op://Personal/auth0.openai.com/amdvas66tob7e3x5v5idfzex4a")
    command llm (string join ' ' $argv)
end
