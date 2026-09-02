import 'dart:convert';

Movie movieFromJson(String str) => Movie.fromJson(json.decode(str));

String movieToJson(Movie data) => json.encode(data.toJson());

class Movie {
    bool adult;
    String backdropPath;
    BelongsToCollection? belongsToCollection;
    int budget;
    List<Genre> genres;
    String homepage;
    int id;
    String imdbId;
    List<String> originCountry;
    String originalLanguage;
    String originalTitle;
    String overview;
    double popularity;
    String posterPath;
    List<ProductionCompany> productionCompanies;
    List<ProductionCountry> productionCountries;
    String releaseDate; 
    int revenue;
    int runtime;
    bool softcore;
    List<SpokenLanguage> spokenLanguages;
    String status;
    String tagline;
    String title;
    bool video;
    double voteAverage;
    int voteCount;
    Videos? videos;
    Credits? credits;
    
    // ✅ genreIds من TMDB API
    List<int> genreIds;
    
    // ✅ الحالات الثلاث
    bool isFavorite;
    bool isWatched;      // ✅ Watched - خلص الفيلم
    bool isWatching;     // ✅ Watching - قيد المشاهدة
    bool isWantToWatch;  // ✅ Want to Watch - عايز يشوفه في المستقبل
    DateTime? watchedDate;
    DateTime? startWatchingDate;
    DateTime? wantToWatchDate;

    Movie({
        required this.adult,
        required this.backdropPath,
        this.belongsToCollection,
        required this.budget,
        required this.genres,
        required this.homepage,
        required this.id,
        required this.imdbId,
        required this.originCountry,
        required this.originalLanguage,
        required this.originalTitle,
        required this.overview,
        required this.popularity,
        required this.posterPath,
        required this.productionCompanies,
        required this.productionCountries,
        required this.releaseDate,
        required this.revenue,
        required this.runtime,
        required this.softcore,
        required this.spokenLanguages,
        required this.status,
        required this.tagline,
        required this.title,
        required this.video,
        required this.voteAverage,
        required this.voteCount,
        required this.genreIds, // ✅ أضف
        this.videos,
        this.credits,
        this.isFavorite = false,
        this.isWatched = false,
        this.isWatching = false,
        this.isWantToWatch = false,
        this.watchedDate,
        this.startWatchingDate,
        this.wantToWatchDate,
    });

    factory Movie.fromJson(Map<String, dynamic> json) => Movie(
        adult: json["adult"] ?? false,
        backdropPath: json["backdrop_path"] ?? '',
        belongsToCollection: json["belongs_to_collection"] != null 
            ? BelongsToCollection.fromJson(json["belongs_to_collection"]) 
            : null,
        budget: json["budget"] ?? 0,
        genres: List<Genre>.from(json["genres"]?.map((x) => Genre.fromJson(x)) ?? []),
        homepage: json["homepage"] ?? '',
        id: json["id"] ?? 0,
        imdbId: json["imdb_id"] ?? '',
        originCountry: List<String>.from(json["origin_country"] ?? []),
        originalLanguage: json["original_language"] ?? '',
        originalTitle: json["original_title"] ?? '',
        overview: json["overview"] ?? '',
        popularity: (json["popularity"] ?? 0.0).toDouble(),
        posterPath: json["poster_path"] ?? '',
        productionCompanies: List<ProductionCompany>.from(
            json["production_companies"]?.map((x) => ProductionCompany.fromJson(x)) ?? []
        ),
        productionCountries: List<ProductionCountry>.from(
            json["production_countries"]?.map((x) => ProductionCountry.fromJson(x)) ?? []
        ),
        releaseDate: json["release_date"] ?? '',
        revenue: json["revenue"] ?? 0,
        runtime: json["runtime"] ?? 0,
        softcore: json["softcore"] ?? false,
        spokenLanguages: List<SpokenLanguage>.from(
            json["spoken_languages"]?.map((x) => SpokenLanguage.fromJson(x)) ?? []
        ),
        status: json["status"] ?? '',
        tagline: json["tagline"] ?? '',
        title: json["title"] ?? '',
        video: json["video"] ?? false,
        voteAverage: (json["vote_average"] ?? 0.0).toDouble(),
        voteCount: json["vote_count"] ?? 0,
        genreIds: List<int>.from(json["genre_ids"] ?? []), // ✅ من TMDB API
        videos: json["videos"] != null ? Videos.fromJson(json["videos"]) : null,
        credits: json["credits"] != null ? Credits.fromJson(json["credits"]) : null,
    );

    Map<String, dynamic> toJson() => {
        "adult": adult,
        "backdrop_path": backdropPath,
        "belongs_to_collection": belongsToCollection?.toJson(),
        "budget": budget,
        "genres": genres.map((x) => x.toJson()).toList(),
        "homepage": homepage,
        "id": id,
        "imdb_id": imdbId,
        "origin_country": originCountry,
        "original_language": originalLanguage,
        "original_title": originalTitle,
        "overview": overview,
        "popularity": popularity,
        "poster_path": posterPath,
        "production_companies": productionCompanies.map((x) => x.toJson()).toList(),
        "production_countries": productionCountries.map((x) => x.toJson()).toList(),
        "release_date": releaseDate,
        "revenue": revenue,
        "runtime": runtime,
        "softcore": softcore,
        "spoken_languages": spokenLanguages.map((x) => x.toJson()).toList(),
        "status": status,
        "tagline": tagline,
        "title": title,
        "video": video,
        "vote_average": voteAverage,
        "vote_count": voteCount,
        "genre_ids": genreIds, // ✅ لـ JSON
        "videos": videos?.toJson(),
        "credits": credits?.toJson(),
    };
    
    // ✅ Movie → Map (لـ SQLite)
    Map<String, dynamic> toMap() {
        return {
            'id': id,
            'title': title,
            'overview': overview,
            'posterPath': posterPath,
            'backdropPath': backdropPath,
            'voteAverage': voteAverage,
            'releaseDate': releaseDate,
            'genreIds': genreIds.join(','), // ✅ لـ SQLite
            'runtime': runtime,
            'status': status,
            'originalLanguage': originalLanguage,
            'isFavorite': isFavorite ? 1 : 0,
            'isWatched': isWatched ? 1 : 0,
            'isWatching': isWatching ? 1 : 0,
            'isWantToWatch': isWantToWatch ? 1 : 0,
            'watchedDate': watchedDate?.toIso8601String(),
            'startWatchingDate': startWatchingDate?.toIso8601String(),
            'wantToWatchDate': wantToWatchDate?.toIso8601String(),
        };
    }
    
    // ✅ Map → Movie (من SQLite)
    factory Movie.fromMap(Map<String, dynamic> map) {
        return Movie(
            adult: false,
            backdropPath: map['backdropPath'] ?? '',
            budget: 0,
            genres: [],
            homepage: '',
            id: map['id'] ?? 0,
            imdbId: '',
            originCountry: [],
            originalLanguage: map['originalLanguage'] ?? '',
            originalTitle: map['title'] ?? '',
            overview: map['overview'] ?? '',
            popularity: 0.0,
            posterPath: map['posterPath'] ?? '',
            productionCompanies: [],
            productionCountries: [],
            releaseDate: map['releaseDate'] ?? '',
            revenue: 0,
            runtime: map['runtime'] ?? 0,
            softcore: false,
            spokenLanguages: [],
            status: map['status'] ?? '',
            tagline: '',
            title: map['title'] ?? '',
            video: false,
            voteAverage: (map['voteAverage'] ?? 0.0).toDouble(),
            voteCount: 0,
            genreIds: map['genreIds'] != null
                ? map['genreIds'].toString().split(',').map((e) => int.tryParse(e) ?? 0).toList()
                : [],
            isFavorite: map['isFavorite'] == 1,
            isWatched: map['isWatched'] == 1,
            isWatching: map['isWatching'] == 1,
            isWantToWatch: map['isWantToWatch'] == 1,
            watchedDate: map['watchedDate'] != null 
                ? DateTime.tryParse(map['watchedDate']) 
                : null,
            startWatchingDate: map['startWatchingDate'] != null 
                ? DateTime.tryParse(map['startWatchingDate']) 
                : null,
            wantToWatchDate: map['wantToWatchDate'] != null 
                ? DateTime.tryParse(map['wantToWatchDate']) 
                : null,
        );
    }
}


class BelongsToCollection {
    int id;
    String name;
    String posterPath;
    String backdropPath;

    BelongsToCollection({
        required this.id,
        required this.name,
        required this.posterPath,
        required this.backdropPath,
    });

    factory BelongsToCollection.fromJson(Map<String, dynamic> json) => BelongsToCollection(
        id: json["id"] ?? 0,
        name: json["name"] ?? '',
        posterPath: json["poster_path"] ?? '',
        backdropPath: json["backdrop_path"] ?? '',
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "poster_path": posterPath,
        "backdrop_path": backdropPath,
    };
}


class Credits {
    List<Cast> cast;
    List<Crew> crew;

    Credits({
        required this.cast,
        required this.crew,
    });

    factory Credits.fromJson(Map<String, dynamic> json) => Credits(
        cast: List<Cast>.from(json["cast"]?.map((x) => Cast.fromJson(x)) ?? []),
        crew: List<Crew>.from(json["crew"]?.map((x) => Crew.fromJson(x)) ?? []),
    );

    Map<String, dynamic> toJson() => {
        "cast": cast.map((x) => x.toJson()).toList(),
        "crew": crew.map((x) => x.toJson()).toList(),
    };
}


class Cast {
    bool adult;
    int gender;
    int id;
    String knownForDepartment;
    String name;
    String originalName;
    double popularity;
    String? profilePath;
    int? castId;
    String? character;
    String creditId;
    int? order;
    String? department;
    String? job;

    Cast({
        required this.adult,
        required this.gender,
        required this.id,
        required this.knownForDepartment,
        required this.name,
        required this.originalName,
        required this.popularity,
        this.profilePath,
        this.castId,
        this.character,
        required this.creditId,
        this.order,
        this.department,
        this.job,
    });

    factory Cast.fromJson(Map<String, dynamic> json) => Cast(
        adult: json["adult"] ?? false,
        gender: json["gender"] ?? 0,
        id: json["id"] ?? 0,
        knownForDepartment: json["known_for_department"] ?? '',
        name: json["name"] ?? '',
        originalName: json["original_name"] ?? '',
        popularity: (json["popularity"] ?? 0.0).toDouble(),
        profilePath: json["profile_path"],
        castId: json["cast_id"],
        character: json["character"],
        creditId: json["credit_id"] ?? '',
        order: json["order"],
        department: json["department"],
        job: json["job"],
    );

    Map<String, dynamic> toJson() => {
        "adult": adult,
        "gender": gender,
        "id": id,
        "known_for_department": knownForDepartment,
        "name": name,
        "original_name": originalName,
        "popularity": popularity,
        "profile_path": profilePath,
        "cast_id": castId,
        "character": character,
        "credit_id": creditId,
        "order": order,
        "department": department,
        "job": job,
    };
}


class Crew {
    bool adult;
    int gender;
    int id;
    String knownForDepartment;
    String name;
    String originalName;
    double popularity;
    String? profilePath;
    String creditId;
    String department;
    String job;

    Crew({
        required this.adult,
        required this.gender,
        required this.id,
        required this.knownForDepartment,
        required this.name,
        required this.originalName,
        required this.popularity,
        this.profilePath,
        required this.creditId,
        required this.department,
        required this.job,
    });

    factory Crew.fromJson(Map<String, dynamic> json) => Crew(
        adult: json["adult"] ?? false,
        gender: json["gender"] ?? 0,
        id: json["id"] ?? 0,
        knownForDepartment: json["known_for_department"] ?? '',
        name: json["name"] ?? '',
        originalName: json["original_name"] ?? '',
        popularity: (json["popularity"] ?? 0.0).toDouble(),
        profilePath: json["profile_path"],
        creditId: json["credit_id"] ?? '',
        department: json["department"] ?? '',
        job: json["job"] ?? '',
    );

    Map<String, dynamic> toJson() => {
        "adult": adult,
        "gender": gender,
        "id": id,
        "known_for_department": knownForDepartment,
        "name": name,
        "original_name": originalName,
        "popularity": popularity,
        "profile_path": profilePath,
        "credit_id": creditId,
        "department": department,
        "job": job,
    };
}


class Genre {
    int id;
    String name;

    Genre({
        required this.id,
        required this.name,
    });

    factory Genre.fromJson(Map<String, dynamic> json) => Genre(
        id: json["id"] ?? 0,
        name: json["name"] ?? '',
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
    };
}


class ProductionCompany {
    int id;
    String? logoPath;
    String name;
    String originCountry;

    ProductionCompany({
        required this.id,
        this.logoPath,
        required this.name,
        required this.originCountry,
    });

    factory ProductionCompany.fromJson(Map<String, dynamic> json) => ProductionCompany(
        id: json["id"] ?? 0,
        logoPath: json["logo_path"],
        name: json["name"] ?? '',
        originCountry: json["origin_country"] ?? '',
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "logo_path": logoPath,
        "name": name,
        "origin_country": originCountry,
    };
}


class ProductionCountry {
    String iso31661;
    String name;

    ProductionCountry({
        required this.iso31661,
        required this.name,
    });

    factory ProductionCountry.fromJson(Map<String, dynamic> json) => ProductionCountry(
        iso31661: json["iso_3166_1"] ?? '',
        name: json["name"] ?? '',
    );

    Map<String, dynamic> toJson() => {
        "iso_3166_1": iso31661,
        "name": name,
    };
}


class SpokenLanguage {
    String englishName;
    String iso6391;
    String name;

    SpokenLanguage({
        required this.englishName,
        required this.iso6391,
        required this.name,
    });

    factory SpokenLanguage.fromJson(Map<String, dynamic> json) => SpokenLanguage(
        englishName: json["english_name"] ?? '',
        iso6391: json["iso_639_1"] ?? '',
        name: json["name"] ?? '',
    );

    Map<String, dynamic> toJson() => {
        "english_name": englishName,
        "iso_639_1": iso6391,
        "name": name,
    };
}

class Videos {
    List<Video> results;

    Videos({
        required this.results,
    });

    factory Videos.fromJson(Map<String, dynamic> json) => Videos(
        results: List<Video>.from(json["results"]?.map((x) => Video.fromJson(x)) ?? []),
    );

    Map<String, dynamic> toJson() => {
        "results": results.map((x) => x.toJson()).toList(),
    };
}

class Video {
    String iso6391;
    String iso31661;
    String name;
    String key;
    String site;
    int size;
    String type;
    bool official;
    String id;
    DateTime publishedAt;

    Video({
        required this.iso6391,
        required this.iso31661,
        required this.name,
        required this.key,
        required this.site,
        required this.size,
        required this.type,
        required this.official,
        required this.id,
        required this.publishedAt,
    });

    factory Video.fromJson(Map<String, dynamic> json) => Video(
        iso6391: json["iso_639_1"] ?? '',
        iso31661: json["iso_3166_1"] ?? '',
        name: json["name"] ?? '',
        key: json["key"] ?? '',
        site: json["site"] ?? '',
        size: json["size"] ?? 0,
        type: json["type"] ?? '',
        official: json["official"] ?? false,
        id: json["id"] ?? '',
        publishedAt: json["published_at"] != null 
            ? DateTime.parse(json["published_at"]) 
            : DateTime.now(),
    );

    Map<String, dynamic> toJson() => {
        "iso_639_1": iso6391,
        "iso_3166_1": iso31661,
        "name": name,
        "key": key,
        "site": site,
        "size": size,
        "type": type,
        "official": official,
        "id": id,
        "published_at": publishedAt.toIso8601String(),
    };
}