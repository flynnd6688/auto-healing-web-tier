FROM nginx:1.27-alpine

# Expose HTTP
EXPOSE 80

HEALTHCHECK --interval=10s --timeout=3s --retries=3 \
  CMD wget -qO- http://localhost/ || exit 1