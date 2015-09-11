#!/bin/sh

if [ -e /usr/local/mail ]; then
    echo "/usr/local/mail already exists!"
    exit 1;
fi

if [ ! -e /var/qmail/bin ]; then
    echo "Qmail not installed??? (/var/qmail/bin is missing)"
    exit 1;
fi

# We pull the mailsystem off bitbucket using the deploy key
TMP=$(tempfile)

cat >$TMP <<EOT
-----BEGIN RSA PRIVATE KEY-----
MIIEoAIBAAKCAQEAjicAtiv6Y23s2VEoaFAc/2o5T7i9OrmPWWjw+KCusfYKo51Y
Iltjz5hdMBoLBYglP6D+no/oYvgnIc8CGBYzd6XPVi/IW5sSLS7ttajJtehf+rK0
fQisUH4znj7KdH78K0PyGPR0a0dS5RIovJ7OkmwtElBIP0FLpcPa7ymVgs1U2RUJ
/nzfGhvKg9q3/Mou/AxVMhjk2E2KL1yebng1QCDgbZlTOSKi4HM3Rhv++O96ogCj
0/gEolfsS4cQIj5oH+AeVMnHzJNybj/xMT8O6MA2wbQFsOtd0/GwPKcqfTgdiWen
zGNGcQN5QbzReYEmE8AZUSCWp5Sf3GrXweLUGwIBJQKCAQA9eKZcnWVbbc40dh9P
s/DdJwQGzG2BLaXFzIPhIuPCk+jszmtNIJndOvfdcwuvXXfkKfGQrO7esH+f6tB5
HltyAoMsMFakJ2HOWXuM014lJjdXpzlK01Fu6ncvrHM5S6tQ+smOQDJX533K12uP
1fh2q1HCuu7PPtSatY8bUECnQ2NC2uhdHxIO11x+0aG4VVBUIwY5uNDONMS5X1pA
FAg1NxmJwqs7yGbIhJidZ1zomKJArC1oqstO2jHAq/zlSvz53YH6/ETPLmeMfOhU
Vtq7aiIYuc1637lhpSxJVw66ZmzTRb1Kj+LhhCVJsJCvDkDVb4Oj4LptivW0aCNA
soKtAoGBANIXfRlLlny7UTQsDeg3FmXnjh2EXOwc4pcVgfgKRsL9hy5ukvvxKHNs
0bbI3hYfMr7hwd1619+6WD1oiZcHDbtYf8q76gdWYsXJ89Y7GvBNzTxLUuSZ6S1N
zZJm/bIEKGNlrzjecWaSwqf9PO5NS3lJ3wsFehqjMAfG9H44CZpZAoGBAK02/bdb
joiceJByiAnLbn9R7TlIQJXekOwtLiWwAx9HikbwdCtNusHD7t+RPuH/28SKsJ1X
FS7BpxvVb8BI80PFkBcEeGFXFV0va0GzG0TJjYudM3Xq3NPUVidsECZqAt57Jykx
hSM0vzsKF5SXZLbcTy3grsznEz/kRYgEPGuTAoGAHGQJ/H/WENsK+TZivoP8G5vU
7ztmgMWiFGqwstD0zj3vrFQhs1fwtabr6ESoY9qz1JsMXDMx7c0S192xunaTJyei
kQSjFb+Qzp7AFgf8uLCRWyzGAzdksxhaDN18OqadrJEzWrZGrP8TYs8xv1aNqJtH
p4seVqBuRj16/EzDBwUCgYBY8rmjWId2lYoE/IsL8tfghAQyLAV9ZHPu5sSrkbxq
AiRpnhIkEyiNA7/alrGWpfs7adBQy9px9L2Yq99wlCnkiAu4yvG1cehgSMhgAgcV
fEHEO/fUxLaWSnFuMJKr8T++WuqYnOOAyA8sJ8brcFZQEERV1D4WMXiWbk04Aizd
SwKBgBH3O2IxQjejX2pZRQWM1srBOC+gycvQ4y0+FWWL6zi+Um49Cmm0CxVFPtlC
jFd6n9kvwpABPCBgrr3jDQHo1yGI5K+jLOMtlmPjXgqm6bnkVk5ROrcpA2xoavlA
uZ14mvObp0iMYTwJQviwi/rc6XCX5vRS7iQeNVmKFq5FARta
-----END RSA PRIVATE KEY-----
EOT

export GIT_SSH=$(tempfile -m 700)
echo "#!/bin/bash" > $GIT_SSH
echo "ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i $TMP \$* 2>/dev/null" >> $GIT_SSH

git clone ssh://git@bitbucket.org/jdelic/mailsystem mail

cp mail/related/vqbin/* /var/qmail/bin

rm $TMP $GIT_SSH

