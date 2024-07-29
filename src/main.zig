const std = @import("std");
const cli = @import("zig-cli");
const udp = @import("./udp_server.zig");

const config = struct { domain_name: []const u8, hops: u32 };

// TODO: make this accept argv
pub fn main() !void {
    const domain = "dns.google.com";
    var socket = try udp.Socket.init("127.0.0.1", 3000);

    // socket.bind();
    // try socket.listen();
    try socket.send("127.0.0.1", 2053, "hello");

    std.debug.print("traceroute to {s}...\n", .{domain});
}
