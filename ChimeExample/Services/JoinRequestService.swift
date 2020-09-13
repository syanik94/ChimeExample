//
//  JoinRequestService.swift
//  ChimeExample
//
//  Created by Yanik Simpson on 9/13/20.
//  Copyright © 2020 Yanik Simpson. All rights reserved.
//

import AmazonChimeSDK
import Foundation

class JoinRequestService: NSObject {
    private static func urlRewriter(url: String) -> String {
        // changing url
        // return url.replacingOccurrences(of: "example.com", with: "my.example.com")
        return url
    }
    
    static func postJoinRequest(meetingId: String, name: String, completion: @escaping (MeetingSessionConfiguration?) -> Void) {
        let encodedURL = HttpHelper.encodeStrForURL(
            str: "\(AppConfiguration.url)join?title=\(meetingId)&name=\(name)&region=\(AppConfiguration.region)"
        )
        HttpHelper.postRequest(url: encodedURL) { result in
            switch result {
            case .success(let data):
                guard let meetingSessionConfiguration = self.processJson(data: data) else {
                    completion(nil)
                    return
                }
                completion(meetingSessionConfiguration)
            case .failure(let err):
                print(err.localizedDescription)
                completion(nil)
            }
        }
    }
    
    private static func processJson(data: Data) -> MeetingSessionConfiguration? {
        let jsonDecoder = JSONDecoder()
        do {
            let joinMeetingResponse = try jsonDecoder.decode(JoinMeetingResponse.self, from: data)
            let meetingResp = getCreateMeetingResponse(from: joinMeetingResponse)
            let attendeeResp = getCreateAttendeeResponse(from: joinMeetingResponse)
            return MeetingSessionConfiguration(createMeetingResponse: meetingResp,
                                               createAttendeeResponse: attendeeResp,
                                               urlRewriter: urlRewriter)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    private static func getCreateMeetingResponse(from joinMeetingResponse: JoinMeetingResponse) -> CreateMeetingResponse {
        let meeting = joinMeetingResponse.joinInfo.meeting.meeting
        let meetingResp = CreateMeetingResponse(meeting:
            Meeting(
                externalMeetingId: meeting.externalMeetingId,
                mediaPlacement: MediaPlacement(
                    audioFallbackUrl: meeting.mediaPlacement.audioFallbackUrl,
                    audioHostUrl: meeting.mediaPlacement.audioHostUrl,
                    signalingUrl: meeting.mediaPlacement.signalingUrl,
                    turnControlUrl: meeting.mediaPlacement.turnControlUrl
                ),
                mediaRegion: meeting.mediaRegion,
                meetingId: meeting.meetingId
            )
        )
        return meetingResp
    }
    
    private static func getCreateAttendeeResponse(from joinMeetingResponse: JoinMeetingResponse) -> CreateAttendeeResponse {
        let attendee = joinMeetingResponse.joinInfo.attendee.attendee
        let attendeeResp = CreateAttendeeResponse(attendee:
            Attendee(attendeeId: attendee.attendeeId,
                     externalUserId: attendee.externalUserId,
                     joinToken: attendee.joinToken)
        )
        return attendeeResp
    }
}
