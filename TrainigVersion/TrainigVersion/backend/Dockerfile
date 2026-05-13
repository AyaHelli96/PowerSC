FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 5051

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY CyberSpaceNIS2.API/CyberSpaceNIS2.API.csproj CyberSpaceNIS2.API/
RUN dotnet restore CyberSpaceNIS2.API/CyberSpaceNIS2.API.csproj
COPY . .
WORKDIR /src/CyberSpaceNIS2.API
RUN dotnet publish -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=build /app/publish .
ENV ASPNETCORE_URLS=http://+:5051
ENV ASPNETCORE_ENVIRONMENT=Production
ENTRYPOINT ["dotnet", "CyberSpaceNIS2.API.dll"]