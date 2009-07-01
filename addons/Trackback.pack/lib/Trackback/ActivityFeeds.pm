package Trackback::ActivityFeeds;

use strict;
use MT::Author qw(AUTHOR);
use MT::Util qw(perl_sha1_digest_hex ts2epoch epoch2ts ts2iso iso2ts
    encode_html encode_url);
use HTTP::Date qw(time2isoz str2time time2str);

sub _feed_ping {
    my ( $cb, $app, $view, $feed ) = @_;

    my $user = $app->user;

    require MT::Blog;
    my $blog;

    # verify user has permission to view entries for given weblog
    my $blog_id = $app->param('blog_id');
    if ($blog_id) {
        if ( !$user->is_superuser ) {
            require MT::Permission;
            my $perm = MT::Permission->load(
                {   author_id => $user->id,
                    blog_id   => $blog_id
                }
            );
            return $cb->error( $app->translate("No permissions.") )
                unless $perm;
        }
        $blog = MT::Blog->load($blog_id) or return;
    }
    else {
        if ( !$user->is_superuser ) {

       # limit activity log view to only weblogs this user has permissions for
            require MT::Permission;
            my @perms = MT::Permission->load( { author_id => $user->id } );
            return $cb->error( $app->translate("No permissions.") )
                unless @perms;
            my @blog_list;
            push @blog_list, $_->blog_id foreach @perms;
            $blog_id = join ',', @blog_list;
        }
    }

    my $link = $app->base
        . $app->mt_uri(
        mode => 'list_pings',
        args => { $blog ? ( blog_id => $blog_id ) : () }
        );
    my $param = {
        feed_link  => $link,
        feed_title => $blog
        ? $app->translate( '[_1] Weblog TrackBacks', $blog->name )
        : $app->translate("All Weblog TrackBacks")
    };

    # user has permissions to view this type of feed... continue
    my $terms = $app->apply_log_filter(
        {   filter     => 'class',
            filter_val => 'ping',
            $blog_id ? ( blog_id => $blog_id ) : (),
        }
    );
    $$feed = $app->process_log_feed( $terms, $param );
}

1;