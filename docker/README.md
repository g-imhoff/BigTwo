# Docker Setup for Godot Game Server

This folder contains everything needed to run your Godot game web export in a Docker container.

## Prerequisites

- Docker installed on your server
- Docker Compose installed on your server
- Your Godot game exported to HTML5/WebGL format in `../godot_project/export`

## How to Use

1. **Export your Godot game**: 
   - In Godot, go to Project > Export
   - Add HTML5 export preset if you don't have one
   - Export to `../godot_project/export` directory
   
2. **Run the Docker container**:
   ```bash
   cd /path/to/projet_chor_dai_di/docker
   docker-compose up -d
   ```

3. **Access your game**:
   - Open a web browser and navigate to `http://your-server-ip`
   - The game should be accessible immediately

## Configuration

- The game files are mounted as a volume, so you can update the export without rebuilding the container
- If you have a backend service, uncomment the backend section in `docker-compose.yml`
- The Nginx configuration in `nginx.conf` is optimized for Godot HTML5 exports

## Connectivity

This setup supports the connectivity checks implemented in your `global.gd` script. The game will:
- Check connectivity every 30 seconds
- Handle disconnections appropriately
- Show disconnection messages to users when needed

## Troubleshooting

- If you can't access the game, check that ports are not blocked by a firewall
- If the game doesn't load properly, verify that all files were correctly exported
- Check Docker logs with `docker-compose logs web`
