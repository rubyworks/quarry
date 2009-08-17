

== Differentiate on empty?

Should the generator be able to diff it's behavior
based on whether the root locatin is empty or not?

If so, we need a way to do varaible manifests. Hmm...
actually we already can:

  <% if something %>

  **/*
  lib/name-                   lib/<%= name %>
  admin/temps/lib/name-       admin/temps/lib/<%= name %>
  admin/temps/lib/name-/*     admin/temps/lib/<%= name %>/

  <% else %>

  admin/**/*                  admin/

  <% end %>

