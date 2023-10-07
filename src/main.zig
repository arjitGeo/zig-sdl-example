const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

pub fn main() !void {
    const CONTENT_W = 3200;
    const CONTENT_H = 2400;
    const WINDOW_W = 800;
    const WINDOW_H = 600;
    const FPS = 90;

    //______________________________________________________________________________________________________________________________________________initi
    if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
        c.SDL_LogError(c.SDL_LOG_CATEGORY_ERROR, "%s", c.SDL_GetError());
        return error.initError;
    }
    defer c.SDL_Quit();

    const window: *c.SDL_Window = c.SDL_CreateWindow("yay square", 800, 150, WINDOW_W, WINDOW_H, c.SDL_WINDOW_SHOWN) orelse {
        c.SDL_LogError(c.SDL_LOG_CATEGORY_ERROR, "%s", c.SDL_GetError());
        return error.windowError;
    };
    defer c.SDL_DestroyWindow(window);

    const renderer: *c.SDL_Renderer = c.SDL_CreateRenderer(window, 0, c.SDL_RENDERER_TARGETTEXTURE | c.SDL_RENDERER_ACCELERATED | c.SDL_RENDERER_PRESENTVSYNC) orelse {
        c.SDL_LogError(c.SDL_LOG_CATEGORY_ERROR, "%s", c.SDL_GetError());
        return error.rendererError;
    };
    defer c.SDL_DestroyRenderer(renderer);

    const texture: *c.SDL_Texture = c.SDL_CreateTexture(renderer, c.SDL_PIXELFORMAT_ABGR8888, c.SDL_TEXTUREACCESS_TARGET, CONTENT_W, CONTENT_H) orelse {
        c.SDL_LogError(c.SDL_LOG_CATEGORY_ERROR, "%s", c.SDL_GetError());
        return error.textureError;
    };
    defer c.SDL_DestroyTexture(texture);

    const keyboard_state = c.SDL_GetKeyboardState(null);

    //______________________________________________________________________________________________________________________________________________setup
    var last_frame_time: u64 = 0;

    var start_point: f32 = @as(f32, @floatFromInt(rando(c.SDL_GetTicks64() + 3, 150, 550)));
    var start_point_2: f32 = @as(f32, @floatFromInt(rando(c.SDL_GetTicks64(), 150, 550)));

    var tr_points: [3]c.SDL_FPoint = [3]c.SDL_FPoint{
        c.SDL_FPoint{ .x = 600, .y = start_point_2 + 400 },
        c.SDL_FPoint{ .x = 800, .y = start_point_2 + 800 },
        c.SDL_FPoint{ .x = 400, .y = start_point_2 + 800 },
    };
    var tr_color: [3]c.SDL_Color = [3]c.SDL_Color{
        c.SDL_Color{ .r = 0xFF, .g = 0x00, .b = 0xFF, .a = 0xFF },
        c.SDL_Color{ .r = 0x00, .g = 0xFF, .b = 0xFF, .a = 0xFF },
        c.SDL_Color{ .r = 0xFF, .g = 0xFF, .b = 0x00, .a = 0xFF },
    };
    var tr_vert: [3]c.SDL_Vertex = [3]c.SDL_Vertex{
        c.SDL_Vertex{ .position = tr_points[0], .color = tr_color[0], .tex_coord = undefined },
        c.SDL_Vertex{ .position = tr_points[1], .color = tr_color[1], .tex_coord = undefined },
        c.SDL_Vertex{ .position = tr_points[2], .color = tr_color[2], .tex_coord = undefined },
    };
    var tr_vel_x: f32 = -450;
    var tr_vel_y: f32 = -450;

    var sq_points: [4]c.SDL_FPoint = [4]c.SDL_FPoint{
        c.SDL_FPoint{ .x = 100, .y = start_point + 100 },
        c.SDL_FPoint{ .x = 500, .y = start_point + 100 },
        c.SDL_FPoint{ .x = 500, .y = start_point + 500 },
        c.SDL_FPoint{ .x = 100, .y = start_point + 500 },
    };
    var sq_colors: [4]c.SDL_Color = [4]c.SDL_Color{
        c.SDL_Color{ .r = 0xFF, .g = 0xFF, .b = 0x00, .a = 0xFF },
        c.SDL_Color{ .r = 0xFF, .g = 0x00, .b = 0x00, .a = 0xFF },
        c.SDL_Color{ .r = 0x00, .g = 0x00, .b = 0xFF, .a = 0xFF },
        c.SDL_Color{ .r = 0x00, .g = 0xFF, .b = 0x00, .a = 0xFF },
    };
    var sq_vert: [4]c.SDL_Vertex = [4]c.SDL_Vertex{
        c.SDL_Vertex{ .position = sq_points[0], .color = sq_colors[0], .tex_coord = undefined },
        c.SDL_Vertex{ .position = sq_points[1], .color = sq_colors[1], .tex_coord = undefined },
        c.SDL_Vertex{ .position = sq_points[2], .color = sq_colors[2], .tex_coord = undefined },
        c.SDL_Vertex{ .position = sq_points[3], .color = sq_colors[3], .tex_coord = undefined },
    };
    var indicies: [6]i32 = [6]i32{ 0, 1, 2, 2, 3, 0 };

    var sq_vel_x: f32 = 400;
    var sq_vel_y: f32 = 400;

    //__________________________________________________________________________________________________________________________________start_of_gameloop
    gameloop: while (true) {
        var event: c.SDL_Event = undefined;
        if (c.SDL_PollEvent(&event) != 0) {
            if (event.type == c.SDL_QUIT) break :gameloop;
        }

        if (keyboard_state[c.SDL_SCANCODE_ESCAPE] != 0) { // temprary
            break :gameloop;
        }

        //_______________________________________________________________________________________________________________________________update_and_input
        var time_to_wait: u64 = (1000 / FPS) -% (c.SDL_GetTicks64() - last_frame_time);

        if (time_to_wait > 0 and time_to_wait <= (1000 / FPS)) {
            c.SDL_Delay(@truncate(time_to_wait));
        }

        var delta_time: f32 = @as(f32, @floatFromInt(c.SDL_GetTicks64() - last_frame_time)) / 1000.0;

        last_frame_time = c.SDL_GetTicks64();

        if (delta_time > 0.133) {
            delta_time = 0.12;
        }

        sq_vert[0].position.x += sq_vel_x * delta_time;
        sq_vert[0].position.y += sq_vel_y * delta_time;
        sq_vert[1].position.x += sq_vel_x * delta_time;
        sq_vert[1].position.y += sq_vel_y * delta_time;
        sq_vert[2].position.x += sq_vel_x * delta_time;
        sq_vert[2].position.y += sq_vel_y * delta_time;
        sq_vert[3].position.x += sq_vel_x * delta_time;
        sq_vert[3].position.y += sq_vel_y * delta_time;

        tr_vert[0].position.x += tr_vel_x * delta_time;
        tr_vert[0].position.y += tr_vel_y * delta_time;
        tr_vert[1].position.x += tr_vel_x * delta_time;
        tr_vert[1].position.y += tr_vel_y * delta_time;
        tr_vert[2].position.x += tr_vel_x * delta_time;
        tr_vert[2].position.y += tr_vel_y * delta_time;

        if (sq_vert[0].position.x < 0 or sq_vert[3].position.x < 0) {
            sq_vert[0].position.x = 0;
            sq_vert[3].position.x = 0;
            sq_vel_x = -sq_vel_x;
        }
        if (sq_vert[1].position.x > CONTENT_W or sq_vert[2].position.x > CONTENT_W) {
            sq_vert[1].position.x = CONTENT_W;
            sq_vert[2].position.x = CONTENT_W;
            sq_vel_x = -sq_vel_x;
        }
        if (sq_vert[0].position.y < 0 or sq_vert[1].position.y < 0) {
            sq_vert[0].position.y = 0;
            sq_vert[1].position.y = 0;
            sq_vel_y = -sq_vel_y;
        }
        if (sq_vert[3].position.y > CONTENT_H or sq_vert[2].position.y > CONTENT_H) {
            sq_vert[3].position.y = CONTENT_H;
            sq_vert[2].position.y = CONTENT_H;
            sq_vel_y = -sq_vel_y;
        }

        if (tr_vert[1].position.x > CONTENT_W) {
            tr_vert[1].position.x = CONTENT_W;
            tr_vel_x = -tr_vel_x;
        }
        if (tr_vert[2].position.x < 0) {
            tr_vert[2].position.x = 0;
            tr_vel_x = -tr_vel_x;
        }
        if (tr_vert[0].position.y < 0) {
            tr_vert[0].position.y = 0;
            tr_vel_y = -tr_vel_y;
        }
        if (tr_vert[1].position.y > CONTENT_H or tr_vert[2].position.y > CONTENT_H) {
            tr_vert[1].position.y = CONTENT_H;
            tr_vert[2].position.y = CONTENT_H;
            tr_vel_y = -tr_vel_y;
        }

        //_________________________________________________________________________________________________________________________________________render
        _ = c.SDL_SetRenderTarget(renderer, texture);
        _ = c.SDL_SetRenderDrawColor(renderer, 0x5D, 0x5D, 0x5D, 0x00);
        _ = c.SDL_RenderClear(renderer);

        _ = c.SDL_SetRenderDrawColor(renderer, 0x00, 0x00, 0x00, 0x00);
        rend_frect(renderer, 50, 50, 50, 50);

        _ = c.SDL_RenderGeometry(renderer, null, &sq_vert, 4, &indicies, 6);
        _ = c.SDL_RenderGeometry(renderer, null, &tr_vert, 3, null, 0);

        _ = c.SDL_SetRenderTarget(renderer, null);
        _ = c.SDL_RenderCopyF(renderer, texture, null, null);
        c.SDL_RenderPresent(renderer);
    }
}

fn rend_rect(renderer: *c.SDL_Renderer, x: f32, y: f32, w: f32, h: f32) void {
    var rect: c.SDL_Rect = c.SDL_Rect{ .x = @as(i32, @intFromFloat(x)), .y = @as(i32, @intFromFloat(y)), .w = @as(i32, @intFromFloat(w)), .h = @as(i32, @intFromFloat(h)) };
    _ = c.SDL_RenderFillRect(renderer, &rect);
}

fn rend_frect(renderer: *c.SDL_Renderer, x: f32, y: f32, w: f32, h: f32) void {
    var rect: c.SDL_FRect = c.SDL_FRect{ .x = x, .y = y, .w = w, .h = h };
    _ = c.SDL_RenderFillRectF(renderer, &rect);
}

fn rando(seed: u64, min: u64, max: u64) u64 {
    return (((seed * 1103515245) + 12345) & 0x7FFFFFFF) % (max - min) + min;
}
