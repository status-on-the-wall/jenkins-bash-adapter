#!/bin/sh

show_help() {
cat << EOF
Usage: ${0##*/} -j JOB_NAME -b BUILD_NUMBER -s STATUS -h HOST -p PORT -u USER -P PASSWORD -t TOPIC
Publish status.
    -j JOB_NAME       name of the job, e.g. tsara-frontend-multibranch/bugfix%2FPUMANEXT-1858
    -b BUILD_NUMBER   build number, e.g. 6
    -s STATUS         status of the build as enum, e.g. SUCCESS, FAILURE, UNSTABLE, CHANGED
    -h HOST           host, e.g. io.adafruit.com
    -p PORT           port, e.g. 1883
    -u USER           user name
    -P PASSWORD       password
    -t TOPIC          topic, for adafruit.io user USER/feeds/TOPIC
EOF
}

# $1 jobName
# $2 buildNumber
# $3 status
prepare_status() {
    echo '{
    jobName: "$1",
    buildNumber: $2,
    status: "$3",
}'
}

mosquitto_pub -h io.adafruit.com -p 1883 -u jczas -P 329f2bd3369c4e52908564eaf7e887b8 -t jczas/feeds/jenkins -m "test"

job_name=""
build_number=""
status=""
host=""
port=""
user=""
password=""
topic=""

while getopts jbshpuPt: opt; do
    case $opt in
        j)
            job_name=$OPTARG
            ;;
        b)
            build_number=$OPTARG
            ;;
        s)
            status=$OPTARG
            ;;
        h)
            host=$OPTARG
            ;;
        p)
            port=$OPTARG
            ;;
        u)
            user=$OPTARG
            ;;
        P)
            password=$OPTARG
            ;;
        t)
            topic=$OPTARG
            ;;
        *)
            show_help >&2
            exit 1
            ;;
    esac
done

json=$(prepare_status "$job_name" "$build_number" "$status")

echo "Prepared json: $json"

mosquitto_pub -h "$host" -p "$port" -u "$user" -P "$password" -t "$topic" -m "$json"
