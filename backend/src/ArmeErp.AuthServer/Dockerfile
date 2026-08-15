# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy project file
COPY ["ArmeErp.AuthServer.csproj", "./"]
RUN dotnet restore "ArmeErp.AuthServer.csproj"

# Copy all source files
COPY . .

# Build and publish
RUN dotnet publish "ArmeErp.AuthServer.csproj" -c Release -o /app/publish

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app

# curl is required by the HEALTHCHECK in docker-compose.yml; the base
# aspnet image doesn't include it.
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /app/publish .

EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080

ENTRYPOINT ["dotnet", "ArmeErp.AuthServer.dll"]
