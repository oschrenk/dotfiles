function transcribe -d "Record audio, transcribe with whisper, and insert into command line"
    # Requirements
    if not set -q WHISPER_MODEL; or test -z "$WHISPER_MODEL"; or not test -e "$WHISPER_MODEL"
        echo "Error: WHISPER_MODEL must be set and point to an existing path"
        return 1
    end

    # Configuration
    set -l audio_file (mktemp /tmp/transcribe_audio.XXXXXX).wav

    set -l txt_file_prefix (mktemp /tmp/transcribe_text.XXXXXX)
    # whisper appends .txt when writing to file
    set -l txt_file {$txt_file_prefix}.txt

    function cleanup
        echo "\nInterrupted. Cleaning up..."
        if set -q sox_pid; and test -n "$sox_pid"
            kill $sox_pid 2>/dev/null
        end
        if test -f $audio_file
            rm -f $audio_file
        end
        if test -f $txt_file
            rm -f $txt_file
        end
        return 1
    end

    # Set up interrupt handler
    trap cleanup INT

    # Start recording in background
    echo "Transcribing... Press Enter to stop."
    sox -d $audio_file >/dev/null 2>&1 &
    set -l sox_pid $last_pid

    # Wait for Enter key
    read -P "" dummy

    # Stop recording
    if test -n "$sox_pid"
        kill $sox_pid 2>/dev/null
        # Give it a moment to terminate gracefully
        sleep 0.1
        # Force kill if still running
        kill -9 $sox_pid 2>/dev/null
    end

    # Check if audio file was created
    if not test -f $audio_file
        echo "Error: Audio file not created"
        return 1
    end

    # Transcribe with whisper-cli
    whisper-cli $audio_file --model $WHISPER_MODEL --output-txt --output-file $txt_file_prefix >/dev/null 2>&1

    # Check if transcription was successful
    if not test -f $txt_file
        echo "Error: Transcription failed"
        return 1
    end

    # Read transcribed text and insert into command line
    set -l transcribed_text (cat $txt_file | string trim)

    if test -n "$transcribed_text"
        commandline -i $transcribed_text
    else
        echo "No text transcribed"
    end

    # Cleanup
    rm -f $audio_file $txt_file
end
