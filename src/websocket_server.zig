const std = @import("std");
const ws = @import("websocket");

const Context = struct {};

pub fn run() !void {
    var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = general_purpose_allocator.allocator();

    // this is the instance of your "global" struct to pass into your handlers
    var context = Context{};

    std.log.info("Running websocket handler on port 8081", .{});
    try ws.listen(Handler, allocator, &context, .{
        .port = 8081,
        .max_headers = 10,
        .address = "0.0.0.0",
    });
}

const Handler = struct {
    conn: *ws.Conn,
    context: *Context,

    pub fn init(h: ws.Handshake, conn: *ws.Conn, context: *Context) !Handler {
        // `h` contains the initial websocket "handshake" request
        // It can be used to apply application-specific logic to verify / allow
        // the connection (e.g. valid url, query string parameters, or headers)

        _ = h; // we're not using this in our simple case

        return Handler{
            .conn = conn,
            .context = context,
        };
    }

    // optional hook that, if present, will be called after initialization is complete
    pub fn afterInit(self: *Handler) !void {
        _ = self;
    }

    pub fn handle(self: *Handler, message: ws.Message) !void {
        const data = message.data;

        var buffer: [1024]u8 = undefined;
        try self.conn.write(try std.fmt.bufPrint(&buffer, "<div hx-swap-oob=\"beforeend:#chat\"><p>{s}</p></div>", .{data}));
    }

    // called whenever the connection is closed, can do some cleanup in here
    pub fn close(_: *Handler) void {}
};
