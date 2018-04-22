function expandurl --description "Retrieve expanded urls from url shortener"
  set url (echo $argv)
  # cookieAbsent guards against http://pubs.acs.org/doi/abs/10.1021/acsenergylett.6b00029 which include a failure location
  set expanded_url (curl --include --silent --location $url | grep '^Location' | grep -v cookieAbsent | tail -1 | awk '{print $2}')
  if test -z $expanded_url
    echo $url
  else
    echo $expanded_url
  end
end
