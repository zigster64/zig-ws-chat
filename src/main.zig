const std = @import("std");
const httpz = @import("httpz");
const wss = @import("websocket_server.zig");

pub fn main() !void {
    var wst = try std.Thread.spawn(.{}, wss.run, .{});
    wst.detach();
    try webserver();
}

fn webserver() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var server = try httpz.Server().init(allocator, .{ .address = "0.0.0.0", .port = 8080 });
    var router = server.router();

    server.notFound(indexHTML);
    router.get("/api/user/:id", getUser);

    // start the server in the current thread, blocking.
    std.log.info("Running server on port 8080", .{});
    try server.listen();
}

fn indexHTML(req: *httpz.Request, res: *httpz.Response) !void {
    _ = req;
    res.body = @embedFile("html/index.html");
}

fn getUser(req: *httpz.Request, res: *httpz.Response) !void {
    try res.json(.{ .id = req.param("id").?, .name = "Teg" }, .{});
}
