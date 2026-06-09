<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.Random" %>
<%
    String[] compliments = {
        "is an absolute legend — future generations will study your brilliance.",
        "has the energy of a golden retriever and the wisdom of a wizard.",
        "makes every room 10% more awesome just by existing.",
        "is so charming that even traffic jams feel inspired by you.",
        "is basically what scientists are trying to clone.",
        "has a smile that could end wars and start fan clubs.",
        "is the human equivalent of finding money in an old jacket.",
        "radiates the kind of confidence that makes motivational posters jealous."
    };

    String[] roasts = {
        "has the personality of a soggy cardboard box — but somehow less flexible.",
        "is proof that evolution occasionally takes a coffee break.",
        "once tried to outsmart a revolving door. The door won.",
        "is the reason instruction manuals exist.",
        "has a face made for radio and a voice made for mime.",
        "is like a software update — nobody asked for it and it makes everything worse.",
        "could bore a PowerPoint presentation to tears.",
        "is living proof that participation trophies were a mistake."
    };

    String name = request.getParameter("name");
    String action = request.getParameter("action");
    String result = null;
    String mode = null;
    String escapedName = "";

    if (name != null && !name.trim().isEmpty() && action != null) {
        name = name.trim();
        escapedName = name.replace("&", "&amp;").replace("<", "&lt;").replace("\"", "&quot;");
        Random rand = new Random();
        if ("compliment".equals(action)) {
            result = name + " " + compliments[rand.nextInt(compliments.length)];
            mode = "compliment";
        } else if ("roast".equals(action)) {
            result = name + " " + roasts[rand.nextInt(roasts.length)];
            mode = "roast";
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Compliment-o-Roast</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #0f0f1a;
            color: #e0e0e0;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 24px;
        }

        .card {
            background: #1a1a2e;
            border: 1px solid #2a2a4a;
            border-radius: 20px;
            padding: 44px 40px;
            max-width: 540px;
            width: 100%;
            box-shadow: 0 12px 40px rgba(0, 0, 0, 0.5);
            text-align: center;
        }

        .logo {
            font-size: 3rem;
            margin-bottom: 10px;
        }

        h1 {
            font-size: 1.9rem;
            font-weight: 700;
            color: #ffffff;
            margin-bottom: 6px;
            letter-spacing: -0.5px;
        }

        .subtitle {
            color: #777;
            font-size: 0.95rem;
            margin-bottom: 32px;
        }

        input[type="text"] {
            width: 100%;
            padding: 15px 20px;
            border-radius: 12px;
            border: 2px solid #2a2a4a;
            background: #0f0f1a;
            color: #ffffff;
            font-size: 1rem;
            margin-bottom: 16px;
            outline: none;
            transition: border-color 0.2s;
        }

        input[type="text"]:focus {
            border-color: #e94560;
        }

        input[type="text"]::placeholder {
            color: #444;
        }

        .buttons {
            display: flex;
            gap: 12px;
        }

        button {
            flex: 1;
            padding: 15px;
            border: none;
            border-radius: 12px;
            font-size: 1rem;
            font-weight: 700;
            cursor: pointer;
            transition: transform 0.1s, filter 0.2s;
            letter-spacing: 0.3px;
        }

        button:hover {
            filter: brightness(1.1);
            transform: translateY(-2px);
        }

        button:active {
            transform: translateY(0);
        }

        .btn-compliment {
            background: linear-gradient(135deg, #22c55e, #16a34a);
            color: #fff;
        }

        .btn-roast {
            background: linear-gradient(135deg, #e94560, #c0392b);
            color: #fff;
        }

        .result-box {
            margin-top: 28px;
            padding: 22px 26px;
            border-radius: 14px;
            font-size: 1.05rem;
            line-height: 1.7;
            text-align: left;
            animation: fadeIn 0.3s ease;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(6px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        .result-compliment {
            background: #0a2a18;
            border-left: 4px solid #22c55e;
            color: #86efac;
        }

        .result-roast {
            background: #2a0a12;
            border-left: 4px solid #e94560;
            color: #fca5a5;
        }

        .result-label {
            font-size: 0.72rem;
            font-weight: 700;
            letter-spacing: 1.5px;
            text-transform: uppercase;
            margin-bottom: 10px;
            opacity: 0.65;
        }

        .result-text {
            font-style: italic;
        }

        .footer {
            margin-top: 32px;
            font-size: 0.82rem;
            color: #444;
        }

        .footer a {
            color: #e94560;
            text-decoration: none;
        }

        .footer a:hover {
            text-decoration: underline;
        }

        .badge {
            display: inline-block;
            margin-top: 20px;
            font-size: 0.72rem;
            color: #333;
            letter-spacing: 0.5px;
        }
    </style>
</head>
<body>
    <div class="card">
        <div class="logo">🔥</div>
        <h1>Compliment-o-Roast</h1>
        <p class="subtitle">Enter a name. Choose your weapon.</p>

        <form method="post" action="index.jsp">
            <input
                type="text"
                name="name"
                id="nameInput"
                placeholder="Enter a name..."
                value="<%= escapedName %>"
                autocomplete="off"
                maxlength="50"
            />
            <div class="buttons">
                <button type="submit" name="action" value="compliment" class="btn-compliment">💚 Compliment</button>
                <button type="submit" name="action" value="roast" class="btn-roast">🔥 Roast</button>
            </div>
        </form>

        <% if (result != null) { %>
        <div class="result-box result-<%= mode %>">
            <div class="result-label">
                <%= "compliment".equals(mode) ? "✨ Compliment" : "🔥 Roast" %>
            </div>
            <div class="result-text">
                "<%= result.replace("&", "&amp;").replace("<", "&lt;") %>"
            </div>
        </div>
        <% } %>

        <div class="footer">
            Built with love (and zero responsibility) &mdash;
            <a href="https://github.com" target="_blank">View on GitHub</a>
        </div>
        <div class="badge">MTA DevOps Final Project &bull; 2026</div>
    </div>
</body>
</html>
