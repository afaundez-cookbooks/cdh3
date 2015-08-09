# cdh3 cookbook

Installs/Configures a single node cluster with Cloudera Dristribution Hadoop 3.

## Supported Platforms

Test on Centos 6.1

## Usage

### hadoop::default

Include `cdh3` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[cdh3::default]"
  ]
}
```

## License and Authors

Author:: Álvaro Faúndez (<alvaro@faundez.net>)

I took a lot of part from this https://github.com/rosarion/hadoop_cluster.
