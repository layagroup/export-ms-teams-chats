[cmdletbinding()]
Param([bool]$verbose)
$VerbosePreference = if ($verbose) { 'Continue' } else { 'SilentlyContinue' }

function ConvertTo-SystemEventMessage ($eventDetail, $clientId, $tenantId) {
    # https://learn.microsoft.com/en-us/graph/system-messages#supported-system-message-events
    switch ($eventDetail."@odata.type") {
        "#microsoft.graph.callEndedEventMessageDetail" {
            "Call ended after $($eventDetail.callDuration)."
            Break
        }
        "#microsoft.graph.callStartedEventMessageDetail" {
            "$(Get-Initiator $eventDetail.initiator $clientId, $tenantId) started a call."
            Break
        }
        "#microsoft.graph.teamJoiningEnabledEventMessageDetail" {
            "$(Get-Initiator $eventDetail.initiator $clientId, $tenantId) allowed to join a team (id: $($eventDetail.teamId))."
            Break
        }
        "#microsoft.graph.callRecordingEventMessageDetail" {
            "$(Get-Initiator $eventDetail.initiator $clientId, $tenantId) starts call recording (Name: $($eventDetail.callRecordingDisplayName)). Duration $($eventDetail.callRecordingDuration). Recording Url $($eventDetail.callRecordingUrl)"
            Break
        }
        "#microsoft.graph.callTranscriptEventMessageDetail" {
            "$(Get-Initiator $eventDetail.meetingOrganizer $clientId, $tenantId) posted call transcript."
            Break
        }
        "#microsoft.graph.chatRenamedEventMessageDetail" {
            "$(Get-Initiator $eventDetail.initiator $clientId, $tenantId) changed the chat name to $($eventDetail.chatDisplayName)."
            Break
        }
        "#microsoft.graph.membersJoinedEventMessageDetail" {
            "$(Get-Initiator $eventDetail.initiator $clientId, $tenantId) added $(($eventDetail.members | ForEach-Object { Get-DisplayName $_.id $clientId $tenantId }) -join ", ")."

            Break
        }
        "#microsoft.graph.membersAddedEventMessageDetail" {
            "$(Get-Initiator $eventDetail.initiator $clientId, $tenantId) added $(($eventDetail.members | ForEach-Object { Get-DisplayName $_.id $clientId $tenantId }) -join ", ")."

            Break
        }
        "#microsoft.graph.membersDeletedEventMessageDetail" {
            if (
                ($eventDetail.members.count -eq 1) -and
                ($null -ne $eventDetail.initiator.user) -and
                ($eventDetail.initiator.user.id -eq $eventDetail.members[0].id)
            ) {
                "$(Get-DisplayName $eventDetail.members[0].id $clientId $tenantId) left."
            }
            else {
                "$(Get-Initiator $eventDetail.initiator $clientId, $tenantId) removed $(($eventDetail.members | ForEach-Object { Get-DisplayName $_.id $clientId $tenantId }) -join ", ")."
            }
            
            Break
        }
        "#microsoft.graph.membersLeftEventMessageDetail" {
            if (
                ($eventDetail.members.count -eq 1) -and
                ($null -ne $eventDetail.initiator.user) -and
                ($eventDetail.initiator.user.id -eq $eventDetail.members[0].id)
            ) {
                "$(Get-DisplayName $eventDetail.members[0].id $clientId $tenantId) left."
            }
            else {
                "$(Get-Initiator $eventDetail.initiator $clientId, $tenantId) removed $(($eventDetail.members | ForEach-Object { Get-DisplayName $_.id $clientId $tenantId }) -join ", ")."
            }
            
            Break
        }
        "#microsoft.graph.messagePinnedEventMessageDetail" {
            "$(Get-Initiator $eventDetail.initiator $clientId, $tenantId) pinned a message."
            Break
        }
        "#microsoft.graph.messageUnpinnedEventMessageDetail" {
            "$(Get-Initiator $eventDetail.initiator $clientId, $tenantId) unpinned a message."
        }
        "#microsoft.graph.teamsAppInstalledEventMessageDetail" {
            "$(Get-Initiator $eventDetail.initiator $clientId, $tenantId) added $($eventDetail.teamsAppDisplayName) here."
        }
        "#microsoft.graph.teamsAppRemovedEventMessageDetail" {
            "$(Get-Initiator $eventDetail.initiator $clientId, $tenantId) removed $($eventDetail.teamsAppDisplayName)."
        }
        Default {
            Write-Warning "Unhandled system event type: $($eventDetail."@odata.type")"
            "Unhandled system event type $($eventDetail."@odata.type"): $($eventDetail | ConvertTo-Json -Depth 5)"
        }
    }
}
