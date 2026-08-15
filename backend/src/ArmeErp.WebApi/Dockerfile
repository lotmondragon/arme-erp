# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy solution and project files
COPY ["ArmeErp.sln", "./"]
COPY ["src/ArmeErp.Domain/ArmeErp.Domain.csproj", "src/ArmeErp.Domain/"]
COPY ["src/ArmeErp.Application/ArmeErp.Application.csproj", "src/ArmeErp.Application/"]
COPY ["src/ArmeErp.Infrastructure/ArmeErp.Infrastructure.csproj", "src/ArmeErp.Infrastructure/"]
COPY ["src/ArmeErp.WebApi/ArmeErp.WebApi.csproj", "src/ArmeErp.WebApi/"]

# Restore dependencies
RUN dotnet restore "src/ArmeErp.WebApi/ArmeErp.WebApi.csproj"

# Copy all source files
COPY . .

# Build and publish
WORKDIR "/src/src/ArmeErp.WebApi"
RUN dotnet publish "ArmeErp.WebApi.csproj" -c Release -o /app/publish

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

ENTRYPOINT ["dotnet", "ArmeErp.WebApi.dll"]
