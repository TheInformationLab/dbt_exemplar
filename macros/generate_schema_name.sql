{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = target.schema -%}
    {%- if custom_schema_name is none -%}

        {{ default_schema }}

    {# Use the custom schema name as full schema in prod runs #}
    {% elif target.name == 'Prod' %}
        {{ custom_schema_name | trim }}

    {# append custom schema name if in dev or staging or other #}
    {%- else -%}

        {{ default_schema }}_{{ custom_schema_name | trim }}

    {%- endif -%}

{%- endmacro %}