import Iter "mo:base/Iter";
import List "mo:base/List";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Debug "mo:base/Debug";
import Array "mo:base/Array";
import Int "mo:base/Int";

actor {
    public type Message = {
        info :Text;
        time : Time.Time;
    };


    public type Microblog = actor {
        follow :shared(Principal) -> async();
        follows : shared query () -> async [Principal];
        post : shared (Text) -> async();
        posts : shared query (Time.Time) -> async [Message];
        timeline : shared (Time.Time) -> async [Message];
    };

    stable var followed : List.List<Principal> = List.nil();

    public shared func follow(id : Principal) : async () {
        followed := List.push(id, followed);
    };

    public shared query func follows () : async [Principal] {
        List.toArray(followed);
    };

    stable var messages : List.List<Message> = List.nil();

    public shared (msg) func post(text : Text) :async () {
        assert(Principal.toText(msg.caller) == "hboae-eawdk-6empe-gmcof-h5t4b-advjl-zpas4-avyhm-ltsfd-aiht7-yqe");
        let message : Message = do {
            var info = text;
            var time = Time.now();
            {
                info = info;
                time = time;
            }
        };
        messages := List.push(message, messages);
        // for (msg in Iter.fromList(messages)) {
        //     Debug.print(msg.info # Int.toText(msg.time));
        // };
    };

    public shared query func posts(since: Time.Time) : async [Message] {
        var all : List.List<Message> = List.nil();
        for (msg in Iter.fromList(messages)) {
            if (since < msg.time) {
                all := List.push(msg, all);
            };
        };
        List.toArray(all);
    };

    public shared func timeline (since: Time.Time) : async [Message] {
        var all : List.List<Message> = List.nil();
        for (id in Iter.fromList(followed)) {
            let canister : Microblog = actor (Principal.toText(id));
            let msgs = await canister.posts(since);
            for (msg in Iter.fromArray(msgs)) {
                all := List.push(msg, all);
            };
        };
        List.toArray(all);
    };
};
