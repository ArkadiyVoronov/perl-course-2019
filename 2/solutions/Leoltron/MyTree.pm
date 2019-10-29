package MyTree;

use strict;
use warnings;
use v5.10;

use Exporter;

use parent qw(Exporter);
our @EXPORT_OK = qw(tree_size tree_size_i tree);

=encoding utf8

=head1 MyTree

Для решения потребуются файловые тесты: perldoc -f -X

Функции:

    opendir

    readdir

Для отладки будет полезен модуль Data::Dumper.

Встроенные модули для обхода древа каталогов использовать нельзя.

=cut

=head2 tree_size()

Возвращает суммарный размер файлов (в байтах) в заданном каталоге. (B<Рекурсивная версия>)

    my $size = tree_size( '~/foo' );

=cut

sub tree_size {
    my ($path) = @_;
    return -s $path if -f $path;

    opendir(my $dir_handle, $path);
    my $result = 0;
    $result += tree_size("$path/$_") foreach grep {$_ !~ /^\.\.?$/} readdir $dir_handle;
    closedir $dir_handle;

    return $result;
}

=head2 tree_size_i()

Возвращает суммарный размер файлов (в байтах) в заданном каталоге. (B<Итеративная версия, необязательное задание>)

    my $size = tree_size( '~/foo' );

=cut

sub tree_size_i {
    my @queue = shift;
    my $size = 0;

    while (my $path = shift @queue) {
        $size += -s $path if -f $path;

        if (-d $path) {
            opendir(my $dir_handle, $path);
            push @queue, map {"$path/$_"} grep {$_ !~ /^\.\.?$/} readdir $dir_handle;
            closedir $dir_handle;
        }
    }

    return $size;
}

=head2 tree()

Возвращает анонимный хэш с древом каталогов. Если передано имя файла - вернёт его размер. (B<Рекурсивная>)

Примеры использования:

    my $size = tree( './foo.txt' );


    my $tree = tree( './a' );

Если содержимое каталога './a' равно a/b/foo.txt, где foo.txt имеет размер 4 байта:

    {
        b => { 'foo.txt' => 4 },
    }

=cut

sub tree {
    my ($path) = @_;
    return -s $path if -f $path;

    opendir(my $dir_handle, $path);
    my %result = map {($_, tree("$path/$_"))} grep {$_ !~ /^\.\.?$/} readdir $dir_handle;
    closedir $dir_handle;

    return \%result;
}

1
