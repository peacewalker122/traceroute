const std = @import("std");
const net = std.net;
const os = std.os.linux;
const log = std.log;
const time = std.time;
const expect = std.testing.expect;
const print = std.debug.print;

test "create a socket" {
    const socket = try Socket.init("127.0.0.1", 3000);
    try expect(@TypeOf(socket.socket) == std.os.socket_t);
}

pub const Socket = struct {
    address: std.net.Address,
    socket: os.socket_t,

    pub fn init(ip: []const u8, port: u16) !Socket {
        const parsed_address = try std.net.Address.parseIp4(ip, port);
        const sock = os.socket(os.AF.INET, os.SOCK.DGRAM, 0);
        errdefer os.closeSocket(sock);
        return Socket{ .address = parsed_address, .socket = @intCast(sock) };
    }

    pub fn bind(self: *Socket) void {
        _ = os.bind(self.socket, &self.address.any, self.address.getOsSockLen());
    }

    pub fn listen(self: *Socket) !void {
        var buffer: [1024]u8 = undefined;

        while (true) {
            const received_bytes = os.recvfrom(self.socket, buffer[0..], 1024, 0, null, null);
            std.debug.print("Received {d} bytes: {s}\n", .{ received_bytes, buffer[0..received_bytes] });

            _ = os.sendto(self.socket, "hello", 5, 0, &self.address.any, self.address.getOsSockLen());
        }
    }

    pub fn send(_: *Socket, ipaddr: []const u8, port: u16, message: []const u8) !void {
        const addr = try net.Address.parseIp(ipaddr, port);

        const sock = os.socket(os.AF.INET, os.SOCK.DGRAM, 0);
        defer _ = os.close(@intCast(sock));

        _ = os.bind(@intCast(sock), &addr.any, addr.getOsSockLen());

        var buf: [1024]u8 = undefined;

        print("Listen on {any}...\n", .{addr});

        const recv = os.sendto(@intCast(sock), message.ptr, message.len, 0, &addr.any, addr.getOsSockLen());

        std.debug.print("Sent {d} bytes: {s}\n", .{ recv, message });

        _ = os.recvfrom(@intCast(sock), buf[0..], 1024, 0, null, null);

        std.debug.print("Received {d} bytes: {s}\n", .{ recv, buf[0..recv] });
    }
};
